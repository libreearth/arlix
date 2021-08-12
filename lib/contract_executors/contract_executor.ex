defmodule Arlix.ContractExecutor do
  use GenServer

  alias Arlix.Contract

  @remote_node_code """
  Process.register(self(), :contract_executor);\
  [parent_process_name, parent_node_name] = System.argv();\
  parent = {String.to_atom(parent_process_name), String.to_atom(parent_node_name)};\
  send(parent, :node_started);\
  Process.monitor(parent);\
  loop = fn loop ->\
    receive do\
      {:define_code, src} ->\
        Code.eval_string(src);\
        loop.(loop);\
      {:execute, owner, method, input, state} ->\
        result = apply(:"Elixir.ArlixContract", :run_contract, [owner, method, input, state]);\
        send(parent, {:result, result});\
        loop.(loop);\
      {:DOWN, _ref, :process, _object, _reason} ->\
          IO.puts("Exiting!!");\
    end;\
  end;\
  loop.(loop)
  """
  def start_link({node_name, _contract} = param) do
    GenServer.start_link(__MODULE__, param, name: process_name(node_name))
  end


  def init({node_name, %{"src" => _src, "state" => _init_state} = contract}) do
    spawn_executor(node_name, contract)
  end

  def handle_call({:execute_contract, owner, method, input}, _from, state) do
    reply = run_contract(state.child_node, owner, method, input, state.contract["state"])
    {:reply, reply, state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state.contract, state}
  end

  def handle_call(:move_to_last_contract_state, _from, state) do
    calculate_last_contract_state(state)
  end

  def handle_call({:update_transaction, wallet, input, method}, _from, state) do
    run_contract_fn = fn owner_pub_key, input, contract_state, method, _source_txt ->
      run_contract(state.child_node, owner_pub_key, method, input, contract_state)
    end
    {reply, new_state} =
      case Contract.run_and_save_contract(wallet, input, method, state.contract, run_contract_fn) do
        {:ok, %{"id" => action_id, "data" => data_encoded} = tx} ->
          contract_state = Base.url_decode64!(data_encoded, padding: false) |> Jason.decode!()
          new_contract = state.contract |> Map.put("state", contract_state) |> Map.put("last_action_id", action_id)
          {tx, state |> Map.put(:contract, new_contract) |> Map.put(:last_evaluated_action_id, action_id)}
        other -> {other, state}
      end
    {:reply, reply, new_state}
  end

  def handle_call(:validate_state, _from, state) do
    run_contract_fn = fn owner_pub_key, input, contract_state, method, _source_txt ->
      run_contract(state.child_node, owner_pub_key, method, input, contract_state)
    end
    case Contract.read_last_contract_state(state.original_contract["id"], run_contract_fn) do
      {:ok, calculated_contract} ->
        validated = calculated_contract == state.contract
        {:reply, validated, state}
      _ -> {:reply, false, state}
    end
  end

  def handle_info({_port, {:data, _text}}, state) do
    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, _object, _reason}, state) do
    case spawn_executor(state.node_name, state.original_contract) do
      {:ok, new_state} -> {:noreply, new_state}
      _ -> {:stop, "Something went wrong with the executor and couldn´t be respawned!!"}
    end
  end

  @doc """
  Executes the contract with the given params and the current executor state and returns the result
  """
  def execute_contract(pid, owner, method, input) do
    GenServer.call(pid, {:execute_contract, owner, method, input})
  end

  @doc """
  Puts the state of the this executor to the last valid state.
  Searches for new actions and try to validate them. The last action validated
  defines the new contract state
  """
  def move_to_last_contract_state(pid) do
    GenServer.call(pid, :move_to_last_contract_state)
  end

  @doc """
  Gets the state of the contract
  """
  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  @doc """
  Updates the transaction with a new state from a contract execution, you need to provide
  a wallet to store and identify

  To obtain a new  `wallet` just call `Arlix.Wallet.new_wallet_map()`,
  otherwise if you have a key file from arweave the wallet can be obtain
  `File.read!("key_file.json") |> Arlix.Wallet.from_json()`
  """
  def update_transaction(pid, wallet, input, method) do
    GenServer.call(pid, {:update_transaction, wallet, input, method})
  end

  @doc """
  Returns true if the current state of the genserver is the same that
  the one calculated from the beguining
  """
  def validate_state(pid) do
    GenServer.call(pid, :validate_state)
  end

  defp process_name(node_name), do: String.to_atom("parent_#{node_name}")

  defp spawn_executor(node_name, %{"src" => src, "state" => _init_state} = contract) do
    elixir_path = System.find_executable("elixir")
    executor_node = "#{node_name}@localhost"
    child_node = {:contract_executor, String.to_atom(executor_node)}
    port =  Port.open({:spawn_executable, elixir_path}, args: ["--sname", executor_node, "--eval", @remote_node_code, process_name(node_name), node()])
    receive do
      :node_started ->
        Process.monitor(child_node)
        send(child_node, {:define_code, src})
        status = %{
          node_name: node_name,
          child_node_name: executor_node,
          child_node: child_node,
          node_port: port,
          original_contract: contract,
          contract: contract,
          last_evaluated_action_id: contract["id"]
        }
        case calculate_last_contract_state(status) do
          {:reply, _new_contract, new_status} -> {:ok, new_status}
          {:error, message} -> {:stop, message}
        end
      after 10_000 ->
        {:stop, "Opening the execution node is taking too much time"}
    end
  end

  defp calculate_last_contract_state(state) do
    run_contract_fn = fn owner_pub_key, input, contract_state, method, _source_txt ->
      run_contract(state.child_node, owner_pub_key, method, input, contract_state)
    end
    case Contract.read_last_contract_from_actions(state.last_evaluated_action_id, state.contract, run_contract_fn) do
      {:ok, new_contract} ->
        {
          :reply,
          new_contract,
          state
          |> Map.put(:contract, new_contract)
          |> Map.put(:last_evaluated_action_id, new_contract["last_action_id"])
        }
      _ ->
        {:error, "Somehitng went wrong calculating the last state of the contract"}
    end
  end

  def run_contract(child_node, owner_pubkey, method, input, contract_state) do
    send(child_node, {:execute, owner_pubkey, method, input, contract_state})
    receive do
      {:result, result} -> result
      after 2_000 -> nil
    end
  end
end
