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
    :ar_tx.sign(transaction, priv, pub)
  end

  def get_addresses(transactions) do
    :ar_tx.get_addresses(transactions)
  end

  def to_map(tx) do
    {:tx, format, id, last_tx, owner, tags, target, quantity, data, data_size, data_tree, data_root, signature, reward} = tx
    %{
      "format" => format,
      "id" => Base.url_encode64(id, padding: false),
      "last_tx" => last_tx,
      "owner" => Base.url_encode64(owner, padding: false),
      "tags" => tags,
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
end
