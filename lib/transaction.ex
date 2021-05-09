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
end
