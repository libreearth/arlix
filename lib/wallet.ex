defmodule Arlix.Wallet do
  def new() do
    :ar_wallet.new()
  end

  def sign(priv, data) do
    :ar_wallet.sign(priv, data)
  end

  def verify(pub, data, signature) do
    :ar_wallet.verify(pub, data, signature)
  end

  def to_address(pub) do
    :ar_wallet.to_address(pub)
  end
end
