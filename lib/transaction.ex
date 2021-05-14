defmodule Arlix.Transaction do
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

  def get_addresses(transactions) do
    :ar_tx.get_addresses(transactions)
  end

  def to_map(tx) do
    {:tx, format, id, last_tx, owner, tags, target, quantity, data, data_size, data_tree, data_root, signature, reward} = tx
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
      "data_tree" => data_tree,
      "data_root" => Base.url_encode64(data_root, padding: false),
      "signature" => Base.url_encode64(signature, padding: false),
      "reward" => Integer.to_string(reward)
    }
  end

  defp prepare_tags(tags) do
    Enum.map(tags, fn {name, value} -> %{"name" => Base.url_encode64(name, padding: false), "value" => Base.url_encode64(value, padding: false)} end)
  end

  def decode_tags(tags) do
    Enum.map(tags, fn %{"name" => name, "value" => value} -> {Base.url_decode64!(name, padding: false), Base.url_decode64!(value, padding: false)} end)
  end
end
