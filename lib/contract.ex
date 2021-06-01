defmodule Arlix.Contract do
  alias Arlix.HttpApi
  alias Arlix.Transaction

  @default_node "https://arweave.net"
  @source_app_name "Arlix-test-src"
  @contract_app_name "Arlix-test-contract"
  @app_version "0.0.1"
  @contract_src_tag "Contract-Src"
  @contract_init_state_tag "Init-State"
  @contract_input "Input"
  @contract_method "Method"
  @tags "tags"

  @doc """
  Uploads Arlix contract source to arweave
  """
  def upload_contract_src(src, %{} = wallet, ar_node \\ @default_node) do
    case HttpApi.upload_data(src, wallet, "application/elixir", src_tags(), ar_node) do
      {:ok, %{"id" => tx_id}} -> {:ok, tx_id}
      error -> error
    end
  end

  defp src_tags() do
    [{"App-Name", @source_app_name}, {"App-Version", @app_version}]
  end

  @doc """
  Uploads the data and initial state of a contract
  """
  def upload_contract_init_data(data, content_type, %{} = init_data, src_id, %{} = wallet, ar_node \\ @default_node) do
    tags = contract_tags(init_data, src_id)
    case HttpApi.upload_data(data, wallet, content_type, tags, ar_node) do
      {:ok, %{"id" => tx_id}} -> {:ok, tx_id}
      error ->  error
    end
  end

  defp contract_tags(%{} = init_data, src_id) do
    [{"App-Name", @contract_app_name}, {"App-Version", @app_version}, {"Init-State", Jason.encode!(init_data)}, {"Contract-Src", src_id}]
  end

  @doc """
  Loads a contract from `contract_id`

  Returns {ok:, %{"src" => src, "init_state" => init_state}}
  """
  def load_contract(contract_id, ar_node \\ @default_node) do
    case HttpApi.get_tx(contract_id, ar_node) do
      {:ok, contract_tx} ->
        src = load_src_from_tx(contract_tx, ar_node)
        init_state = load_init_state(contract_tx) |> Jason.decode!()
        build_contract_map(src, init_state, contract_id)
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Loads an action with the given `contract_id`
  """
  def load_action(contract_id, ar_node \\ @default_node) do
    HttpApi.get_tx(contract_id, ar_node)
  end

  @doc """
  Given a `wallet` and an `action_id`
  Returns the map of the contract if the action_id is valid, or {:error, "the reason"}
  otherwise
  """
  def validate_action(wallet, action_id, contract,  ar_node \\ @default_node) do
    case load_action(action_id) do
      {:ok, action_tx} ->
        input = load_input(action_tx) |> Jason.decode!()
        method = load_method(action_tx)
        case run_contract(wallet, input, contract["state"], method, contract["src"]) do
          {:ok, state} ->
            case HttpApi.get_data(action_id, ar_node)  do
              {:ok, pre_computed_state_txt} ->
                pre_computed_state = Jason.decode!(pre_computed_state_txt)
                if pre_computed_state == state do
                  {:ok, %{contract | "state" => state}}
                else
                  {:error, "invalid action state"}
                end
            end
          other -> other
        end
      error -> error
    end
  end

  @doc """
  Given a map `wallet` and a `contract_id`
  Returns the contract map with the id of the contract and the last valid state
  of the contract {:ok, last_valid_contract_state} or {:error, "the reason"}
  """
  def read_last_contract_state(wallet, contract_id, ar_node \\ @default_node ) do
    case load_contract(contract_id) do
      {:ok, contract}  ->
        case HttpApi.find_actions(contract_id, ar_node) do
          {:ok, action_ids} ->
            {
              :ok,
              Enum.reduce(action_ids, contract, fn (action_id, acc_contract) ->
                case validate_action(wallet, action_id, acc_contract) do
                  {:ok, new_contract} -> new_contract
                  _other -> acc_contract
                end
              end)
            }
          error -> error
        end
      error -> error
    end
  end

  @doc """
  Calculates the last state of a contract and then, given an input and a method calculates next state and saves it.
  """
  def update_contract(wallet, contract_id, input, method, ar_node \\ @default_node) do
    case read_last_contract_state(wallet, contract_id, ar_node) do
      {:ok, contract} ->
        case run_contract(wallet, input, contract["state"], method, contract["src"]) do
          {:ok, new_state} ->save_action(wallet, new_state, contract_id, input, method, ar_node)
          other -> other
        end
      other -> other
    end
  end

  defp save_action(wallet, state, contract_id, input, method, ar_node) do
    bin_state = Jason.encode!(state)
    HttpApi.upload_data(bin_state, wallet, "application/json", action_tags(contract_id, input, method), ar_node)
  end

  defp action_tags(contract_id, input, method) do
    [{"App-Name", @contract_app_name}, {"App-Version", @app_version}, {"Contract", contract_id}, {@contract_input,  Jason.encode!(input)}, {@contract_method, method} ]
  end

  defp run_contract(%{} = wallet,%{} = input, %{} = init_state, method, source_txt) do
    Code.eval_string(source_txt)
    ArlixContract.run_contract(wallet["n"], method, input, init_state)
  end

  defp load_src_from_tx(contract_tx, ar_node) do
    src_id =
      contract_tx
      |> Map.get(@tags)
      |> Transaction.decode_tags()
      |> get_from_tags(@contract_src_tag)
    case src_id do
      nil -> nil
      src_id -> load_source_from_id(src_id, ar_node)
    end
  end

  defp load_init_state(contract_tx) do
    contract_tx
    |> Map.get(@tags)
    |> Transaction.decode_tags()
    |> get_from_tags(@contract_init_state_tag)
  end

  defp load_input(contract_tx) do
    contract_tx
    |> Map.get(@tags)
    |> Transaction.decode_tags()
    |> get_from_tags(@contract_input)
  end

  defp load_method(contract_tx) do
    contract_tx
    |> Map.get(@tags)
    |> Transaction.decode_tags()
    |> get_from_tags(@contract_method)
  end

  defp build_contract_map(src, init_state, contract_id) do
    case {src, init_state} do
      {nil, _init_state} -> {:error, "Error no src"}
      {_src, nil} -> {:error, "Error no init state"}
      {src, init_state} -> {:ok, %{"src" => src, "state" => init_state, "id" => contract_id}}
    end
  end

  defp get_from_tags(tags, name_txt) do
    case Enum.find(tags, fn {name, _value} -> name == name_txt end) do
      {_name_txt, value} -> value
      _ -> nil
    end
  end

  defp load_source_from_id(src_id, ar_node) do
    case HttpApi.get_data(src_id, ar_node) do
      {:ok, src} -> src
      _ -> {:error, "http error"}
    end
  end
end
