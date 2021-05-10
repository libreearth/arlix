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

  def new_wallet_map() do
    to_map(new())
  end

  def to_map({[expnt, pub], [expnt, pub, priv, p1, p2, e1, e2, c]}) do
    %{
      "kty" => "RSA",
      "e" => Base.url_encode64(expnt, padding: false),
      "n" => Base.url_encode64(pub, padding: false),
      "d" => Base.url_encode64(priv, padding: false),
      "p" => Base.url_encode64(p1, padding: false),
      "q" => Base.url_encode64(p2, padding: false),
      "dp" => Base.url_encode64(e1, padding: false),
      "dq" => Base.url_encode64(e2, padding: false),
      "qi" => Base.url_encode64(c, padding: false)
    }
  end

  def to_map({{priv, pub}, pub}) do
    %{
      "n" => Base.url_encode64(pub, padding: false),
      "d" => Base.url_encode64(priv, padding: false),
    }
  end

  def to_json(wallet_map) do
    Jason.encode!(wallet_map)
  end

  def from_json(text) do
    Jason.decode!(text)
  end

end
