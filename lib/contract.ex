defmodule Arlix.Contract do
  alias Arlix.HttpApi
  alias Arlix.Transaction

  @default_node "https://arweave.net"
  @source_app_name "Arlix-test-src"
  @contract_app_name "Arlix-test-contract"
  @app_version "0.0.1"
  @contract_src_tag "Contract-Src"
  @contract_init_state_tag "Init-State"
  @tags "tags"

  @doc """
  Uploads Arlix contract source to arweave
  """
  def upload_contract_src(src, %{} = wallet, ar_node \\ @default_node) do
    case HttpApi.upload_data(src, wallet, "application/elixir", src_tags(), ar_node) do
      %{"id" => tx_id} -> {:ok, tx_id}
      error -> {:error, error}
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
      %{"id" => tx_id} -> {:ok, tx_id}
      error -> {:error, error}
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
        build_contract_map(src, init_state)
      {:error, reason} -> {:error, reason}
    end
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

  defp build_contract_map(src, init_state) do
    case {src, init_state} do
      {nil, _init_state} -> {:error, "Error no src"}
      {_src, nil} -> {:error, "Error no init state"}
      {src, init_state} -> {:ok, %{"src" => src, "init_state" => init_state}}
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
