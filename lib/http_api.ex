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
    wallet_map["n"]
    |> Base.url_decode64!(padding: false)
    |> Wallet.to_address()
    |> get_address_last_tx(ar_node)
  end

  def get_address_last_tx(address, ar_node \\ @default_node) do
    Base.url_encode64(address, padding: false)
    |> get_url_address_last_tx(ar_node)
  end

  def get_url_address_last_tx(url_address, ar_node \\ @default_node) do
    case HTTPoison.get("#{ar_node}/wallet/#{url_address}/last_tx") do
      {:ok, response} ->
        response.body
      _ -> nil
    end
  end

  def upload_data(data, wallet_map, ar_node \\ @default_node) do
    price = get_data_tx_price(byte_size(data), ar_node)
    last_tx = get_wallet_last_tx(wallet_map, ar_node)
    priv = wallet_map["n"] |> Base.url_decode64!(padding: false)
    pub = wallet_map["d"] |> Base.url_decode64!(padding: false)
    tx_text =
      Transaction.new(data, price, last_tx)
      |> Transaction.sign(priv,pub)
      |> Transaction.to_map()
      |> Jason.encode!()
    HTTPoison.post("#{ar_node}/tx", tx_text, [{"Accept", "application/json"}, {"Content-Type", "application/json"}])
  end
end
