defmodule Arlix.HttpApi do
  alias Arlix.Wallet
  alias Arlix.Transaction

  @default_node "https://arweave.net"

  def default_node() do
    @default_node
  end

  @doc """
  Gets data upload price of a size of `size_bytes`

  Returns an integer with the cost in Winstons
  """
  def get_data_tx_price!(size_bytes, ar_node \\ @default_node) do
    case HTTPoison.get("#{ar_node}/price/#{size_bytes}") do
      {:ok, response} ->
        String.to_integer(response.body)
      _ -> nil
    end
  end

  @doc """
  Gets last transaction from a wallet. To obtain a new  `wallet_map` just call `Arlix.Wallet.new_wallet_map()`
  otherwise if you have a key file from arweave the wallet can be obtain `File.read!("key_file.json") |> Arlix.Wallet.from_json()`

  Returns the last transacion id
  """
  def get_wallet_last_tx!(wallet_map, ar_node \\ @default_node) do
    wallet_map
    |> wallet_map_to_address()
    |> get_url_address_last_tx(ar_node)
  end


  defp get_url_address_last_tx(url_address, ar_node) do
    case HTTPoison.get("#{ar_node}/wallet/#{url_address}/last_tx") do
      {:ok, response} ->
        response.body
      _ -> nil
    end
  end


  @doc """
  Uploads data to ArWeave using a data transaction. `data` is the data to be uploaded.
  To obtain a new  `wallet_map` just call `Arlix.Wallet.new_wallet_map()`,
  otherwise if you have a key file from arweave the wallet can be obtain
  `File.read!("key_file.json") |> Arlix.Wallet.from_json()`

  Returns a map with the transaction fields
  """
  def upload_data(data, %{} = wallet_map, content_type, tags \\ [], ar_node \\ @default_node) do
    Transaction.create_data_transaction(data, wallet_map, nil, content_type, tags, ar_node)
    |> post_transaction(ar_node)
  end

  def post_transaction(tx_map, ar_node \\ @default_node) do
    case HTTPoison.post("#{ar_node}/tx", Jason.encode!(tx_map) , [{"Accept", "application/json"}, {"Content-Type", "application/json"}]) do
      {:ok, response} ->
        case response.status_code do
          200 -> {:ok, tx_map}
          _sc -> {:error, response.body}
        end
       _ -> {:error, "http error"}
    end
  end

  @doc """
  Gets the transaction status. `tx_id_base64` can be obtained from the field "id"
  of the map returned by `upload_data`

  Returns a string describing the transaction status
  """
  def transaction_status!(tx_id_base64, ar_node \\ @default_node) do
    case HTTPoison.get("#{ar_node}/tx/#{tx_id_base64}/status") do
       {:ok, response} -> response.body
       _ -> nil
    end
  end

  def transaction_status(tx_id_base64, ar_node \\ @default_node) do
    HTTPoison.get("#{ar_node}/tx/#{tx_id_base64}/status")
  end

  @doc """
  Gets a transaction status and clasify the message, return :pending, :not_found, :ok
  """
  def tx_status(tx_id_base64, ar_node \\ @default_node) do
    case transaction_status!(tx_id_base64, ar_node) do
      "Pending" -> :pending
      "{\"status\":400,\"error\":\"Invalid address.\"}" -> :not_found
      _ -> :ok
    end
  end

  @doc """
  Gets the amount of Winstons in the given `wallet_map`
  To obtain a new  `wallet_map` just call `Arlix.Wallet.new_wallet_map()`,
  otherwise if you have a key file from arweave the wallet can be obtain
  `File.read!("key_file.json") |> Arlix.Wallet.from_json()`
  """
  def wallet_balance(wallet_map, ar_node \\ @default_node) do
    wallet_address = wallet_map_to_address(wallet_map)
    case HTTPoison.get("#{ar_node}/wallet/#{wallet_address}/balance") do
      {:ok, response} -> {:ok, Jason.decode!(response.body)}
      _ -> {:error, "http error"}
    end
  end

  defp wallet_map_to_address(wallet_map) do
    wallet_map["n"]
    |> Base.url_decode64!(padding: false)
    |> Wallet.to_address()
    |> Base.url_encode64(padding: false)
  end

  @doc """
  Get transaction
  """
  def get_tx(tx_id, ar_node \\ @default_node) do
    case HTTPoison.get("#{ar_node}/tx/#{tx_id}") do
      {:ok, response} ->
        case response.status_code do
          200 -> {:ok, Jason.decode!(response.body)}
          202 -> {:pending, response.body}
        end
      _ -> {:error, "http error"}
    end
  end

  @doc """
  Get data of a transaction
  """
  def get_data(tx_id,  ar_node \\ @default_node) do
    case HTTPoison.get("#{ar_node}/tx/#{tx_id}/data") do
      {:ok, response} ->
        case response.status_code do
          200 -> {:ok, Base.url_decode64!(response.body, padding: false)}
          202 -> {:pending, response.body}
        end
      _ -> {:error, "http error"}
    end
  end

  @doc """
  Query the actions that reference the `contract_id`
  """
  def find_actions(contract_id, ar_node \\ @default_node) do
    response =
      Neuron.query("""
        query {
          transactions(
            sort: HEIGHT_ASC,
            tags: [
              {
                name: "Contract",
                values:["#{contract_id}"]
              }
            ]
          ) {
            edges {
              node {
                id
              }
            }
          }
        }
        """,
        %{},
        url: "#{ar_node}/graphql"
      )

    case response do
      {:ok, %Neuron.Response{body: %{"data" => %{"transactions" => %{"edges" => edges}}}}} -> {:ok, Enum.map(edges, fn %{"node" => %{"id" => id}} -> id end)}
      _ -> {:error, "Query error"}
    end
  end

end
