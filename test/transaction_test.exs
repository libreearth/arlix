defmodule TransactionTest do
  use ExUnit.Case

  alias Arlix.Transaction

  @tags [
          %{"name" => "QXBwLU5hbWU", "value" => "U21hcnRXZWF2ZUNvbnRyYWN0U291cmNl"},
          %{"name" => "QXBwLVZlcnNpb24", "value" => "MC4zLjA"},
          %{"name" => "Q29udGVudC1UeXBl", "value" => "YXBwbGljYXRpb24vamF2YXNjcmlwdA"}
        ]

  test "decode tags" do
    decoded = Transaction.decode_tags(@tags)
    assert {"App-Name", "SmartWeaveContractSource"} = List.first(decoded)
  end

end
