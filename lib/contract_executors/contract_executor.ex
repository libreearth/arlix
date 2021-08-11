defmodule Arlix.ContractExecutor do
  use GenServer

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
    send(state.child_node, {:execute, owner, method, input, state.contract_state})
    receive do
      {:result, result} ->
        {:reply, result, state}
      after 2_000 ->
        {:reply, nil, state}
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
          contract_state: contract["state"]
        }
        {:ok, status}
      after 10_000 ->
        {:stop, "Opening the execution node is taking too much time"}
    end
  end
end
