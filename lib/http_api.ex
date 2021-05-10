defmodule Arlix.HttpApi do
  @default_node "https://arweave.net"
  alias Arlix.Wallet
  alias Arlix.Transaction

  def get_data_tx_price(size_bytes, ar_node \\ @default_node) do
    case HTTPoison.get("#{ar_node}/price/#{size_bytes}") do
      {:ok, response} ->
        String.to_integer(response.body)
      _ -> nil
    end
  end

  def get_wallet_last_tx(wallet_map, ar_node \\ @default_node) do
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

  def upload_data(data, wallet_map, ar_node \\ @default_node) do
    price = get_data_tx_price(byte_size(data), ar_node)
    last_tx = get_wallet_last_tx(wallet_map, ar_node)
    pub = wallet_map["n"] |> Base.url_decode64!(padding: false)
    priv = wallet_map["d"] |> Base.url_decode64!(padding: false)
    tx_map =
      Transaction.new(data, price, last_tx)
      |> Transaction.sign(priv,pub)
      |> Transaction.to_map()
    tx_text = Jason.encode!(tx_map)
    case HTTPoison.post("#{ar_node}/tx", tx_text, [{"Accept", "application/json"}, {"Content-Type", "application/json"}]) do
      {:ok, response} ->
        case response.status_code do
          200 -> tx_map
          _sc -> response.body
        end
       _ -> nil
    end
  end

  def transaction_status(tx_id_base64, ar_node \\ @default_node) do
    case HTTPoison.get("#{ar_node}/tx/#{tx_id_base64}/status") do
       {:ok, response} -> response.body
       _ -> nil
    end
  end

  def wallet_balance(wallet_map, ar_node \\ @default_node) do
    wallet_address = wallet_map_to_address(wallet_map)
    case HTTPoison.get("#{ar_node}/wallet/#{wallet_address}/balance") do
      {:ok, response} -> Jason.decode!(response.body)
      _ -> nil
   end
  end

  defp wallet_map_to_address(wallet_map) do
    wallet_map["n"]
    |> Base.url_decode64!(padding: false)
    |> Wallet.to_address()
    |> Base.url_encode64(padding: false)
  end
end
