defmodule Arlix.Transaction do
  import Arlix.Tx

  @default_node Arlix.HttpApi.default_node

  def new() do
    :ar_tx.new()
  end

  def new(data) do
    :ar_tx.new(data)
  end

  def new(data, reward) do
    :ar_tx.new(data, reward)
  end

  def new(data, reward, last) do
    :ar_tx.new(data, reward, last)
  end

  def new(data, reward, quantity, last) do
    :ar_tx.new(data, reward, quantity, last)
  end

  def sign(transaction, priv, pub) do
    :ar_tx.sign_v1(transaction, priv, pub)
  end

  def sign_v2(transaction, priv, pub) do
    tx = :ar_tx.generate_chunk_tree(transaction)
    tx_v2 = tx(tx, format: 2)
    :ar_tx.sign(tx_v2, priv, pub)
  end

  def get_addresses(transactions) do
    :ar_tx.get_addresses(transactions)
  end

    @doc """
    Creates and sing a data transaction with the given information
  """
  def create_data_transaction(data, wallet_map, last_tx, content_type, tags \\ [], ar_node \\ @default_node)

  def create_data_transaction(data, %{} = wallet_map, nil, content_type, tags, ar_node) do
    last_tx = Arlix.HttpApi.get_wallet_last_tx!(wallet_map, ar_node)
    create_data_transaction(data, wallet_map, last_tx, content_type, tags, ar_node)
  end


  def create_data_transaction(data, %{} = wallet_map, last_tx, content_type, tags, ar_node) do
    price = Arlix.HttpApi.get_data_tx_price!(byte_size(data), ar_node)
    pub = wallet_map["n"] |> Base.url_decode64!(padding: false)
    priv = wallet_map["d"] |> Base.url_decode64!(padding: false)
    build_and_sign_data_transaction(data, price, last_tx, content_type, priv, pub, tags)
  end

  @doc """
  Create data transaction type v2
  """
  def create_v2_data_transaction(data, wallet_map, last_tx, content_type, tags \\ [], ar_node \\ @default_node)

  def create_v2_data_transaction(data, %{} = wallet_map, last_tx, content_type, tags, ar_node) do
    price = Arlix.HttpApi.get_data_tx_price!(byte_size(data), ar_node)
    pub = wallet_map["n"] |> Base.url_decode64!(padding: false)
    priv = wallet_map["d"] |> Base.url_decode64!(padding: false)
    build_and_sign_v2_data_transaction(data, price, last_tx, content_type, priv, pub, tags)
  end

  @doc """
    Creates and sing a data transaction with the given information
  """
  def build_and_sign_data_transaction(data, price, last_tx, content_type, priv, pub, tags \\ []) do
    new(data, price, decode_last_tx(last_tx))
    |> set_tags([{"Content-Type", content_type}]++tags)
    |> sign(priv,pub)
    |> to_map()
  end

  def build_and_sign_v2_data_transaction(data, price, last_tx, content_type, priv, pub, tags \\ []) do
    new(data, price, decode_last_tx(last_tx))
    |> set_tags([{"Content-Type", content_type}]++tags)
    |> sign_v2(priv,pub)
    |> to_map_v2()
  end

  def to_map(tx) do
    {:tx, format, id, last_tx, owner, tags, target, quantity, data, data_size, _data_tree, data_root, signature, reward} = tx
    %{
      "format" => format,
      "id" => Base.url_encode64(id, padding: false),
      "last_tx" => Base.url_encode64(last_tx, padding: false),
      "owner" => Base.url_encode64(owner, padding: false),
      "tags" => prepare_tags(tags),
      "target" => Base.url_encode64(target, padding: false),
      "quantity" => Integer.to_string(quantity),
      "data" => Base.url_encode64(data, padding: false),
      "data_size" => Integer.to_string(data_size),
      #"data_tree" => data_tree,
      "data_root" => Base.url_encode64(data_root, padding: false),
      "signature" => Base.url_encode64(signature, padding: false),
      "reward" => Integer.to_string(reward)
    }
  end

  def to_map_v2(tx) do
    {:tx, format, id, last_tx, owner, tags, target, quantity, data, data_size, data_tree, data_root, signature, reward} = tx
    {
      %{
        "format" => format,
        "id" => Base.url_encode64(id, padding: false),
        "last_tx" => Base.url_encode64(last_tx, padding: false),
        "owner" => Base.url_encode64(owner, padding: false),
        "tags" => prepare_tags(tags),
        "target" => Base.url_encode64(target, padding: false),
        "quantity" => Integer.to_string(quantity),
        "data" => Base.url_encode64(data, padding: false),
        "data_size" => Integer.to_string(data_size),
        "data_root" => Base.url_encode64(data_root, padding: false),
        "signature" => Base.url_encode64(signature, padding: false),
        "reward" => Integer.to_string(reward)
      },
      data_tree
    }
  end

  defp set_tags(transaction, tags) do
    tx(transaction, tags: tags)
  end

  defp prepare_tags(tags) do
    Enum.map(tags, fn {name, value} -> %{"name" => Base.url_encode64(name, padding: false), "value" => Base.url_encode64(value, padding: false)} end)
  end

  defp decode_last_tx(last_tx) do
    Base.url_decode64!(last_tx, padding: false)
  end

  def decode_tags(tags) do
    Enum.map(tags, fn %{"name" => name, "value" => value} -> {Base.url_decode64!(name, padding: false), Base.url_decode64!(value, padding: false)} end)
  end
end
