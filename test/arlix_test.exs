defmodule ArlixTest do
  use ExUnit.Case
  doctest Arlix

  import Arlix.Tx


  test "sign with wallet" do
    {priv, pub} = Arlix.new_wallet()
    test_data = "test data"

    signature = :ar_wallet.sign(priv, test_data)

    assert true =  :ar_wallet.verify(pub, test_data, signature)
  end

  test "sign transaction" do
    {priv, pub} = :ar_wallet.new()
    test_data = "test data"
    unsigned_tx = :ar_tx.new(test_data)
    IO.inspect tx(unsigned_tx)

    id = tx(unsigned_tx, :id) |> to_string()

    signed_tx = :ar_tx.sign(unsigned_tx, priv, pub)
    IO.inspect tx(signed_tx)
  end
end
