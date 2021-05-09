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

  test "sign transaction" do
    {priv, pub} = Wallet.new()
    ### TODO load wallet {{Priv, Pub}, Pub} from file DB

    test_data =
    """
    Earth
    Regeneration
    Age
    """

    #unsigned_tx = :ar_tx.new(@test_data)
    #unsigned_tx = tx(data: test_data)
    unsigned_tx = tx(tags: [{"Content-Type", "text/plain"}], data: test_data)
    #IO.inspect unsigned_tx
    IO.inspect tx(unsigned_tx)
    #id = tx(unsigned_tx, :id)
    #IO.inspect id

    #signed_tx = :ar_tx.sign(unsigned_tx, priv, pub)

    ### ar_tx:sign(
		###			TX#tx {
		###				last_tx = LastTXid, ### From api:
		###				reward = Price, ### From api https://github.com/kirecek/elixir-arweave-sdk/blob/3762c88d7c1b1536d766aeeab94238f6c6d51a4a/lib/arweave/transactions.ex#L47
		###				tags = Tags
		###			},
		###			S#state.wallet
		###		)

    signed_tx = Transaction.sign(unsigned_tx, priv, pub)
    IO.inspect tx(signed_tx)
    id = tx(signed_tx, :id)

    ### TODO submit transaction with api https://github.com/kirecek/elixir-arweave-sdk/blob/3762c88d7c1b1536d766aeeab94238f6c6d51a4a/lib/arweave/transactions.ex#L68

    addresses = Transaction.get_addresses([signed_tx])

    #IO.inspect addresses

  end
end
