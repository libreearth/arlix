defmodule ArlixTest do
  use ExUnit.Case
  doctest Arlix

  alias Arlix.Transaction
  alias Arlix.Wallet

  import Arlix.Tx


  test "sign with wallet" do
    test_data =
    """
    Earth
    Regeneration
    Age
    """
    {priv, pub} = Wallet.new()

    address = Wallet.to_address(pub)

    signature = Wallet.sign(priv, test_data)

    assert true =  Wallet.verify(pub, test_data, signature)
  end

  test "create wallet" do
    wall = Wallet.new_wallet_map()
    assert wall["n"]!=nil
    assert wall["d"]!=nil
  end

  test "sing data transaction with wallet" do
    price = 9128374098
    last_tx = "alisduohociasudofiho8asdfh"
    data =
      """
      Earth
      Regeneration
      Age
      """
    {{priv, pub}, pub} = Wallet.new()
    tx_map =
      Transaction.new(data, price, last_tx)
      |> Transaction.sign(priv, pub)
      |> Transaction.to_map()

    assert tx_map["id"] != nil
    assert tx_map["signature"] != nil
    assert tx_map["owner"] == Base.url_encode64(pub, padding: false)
  end



end
