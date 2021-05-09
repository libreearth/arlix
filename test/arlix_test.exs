defmodule ArlixTest do
  use ExUnit.Case
  doctest Arlix

  alias Arlix.Transaction
  alias Arlix.Wallet

  import Arlix.Tx


  test "sign with wallet" do
    {priv, pub} = Wallet.new()
    test_data = "test data"

    address = Wallet.to_address(pub)

    signature = Wallet.sign(priv, test_data)

    assert true =  Wallet.verify(pub, test_data, signature)
  end

  test "sign transaction" do
    {priv, pub} = Wallet.new()
    test_data = "test data"
    unsigned_tx = :ar_tx.new(test_data)
    #unsigned_tx = tx(data: test_data)
    #IO.inspect unsigned_tx
    IO.inspect tx(unsigned_tx)
    id = tx(unsigned_tx, :id)
    #IO.inspect id

    #signed_tx = :ar_tx.sign(unsigned_tx, priv, pub)
    signed_tx = Transaction.sign(unsigned_tx, priv, pub)
    IO.inspect tx(signed_tx)
    id = tx(signed_tx, :id)

    addresses = Transaction.get_addresses([signed_tx])

    #IO.inspect addresses

  end
end
