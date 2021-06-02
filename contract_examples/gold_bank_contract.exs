defmodule ArlixContract do
  def run_contract(owner, "transfer", %{"to" => to, "quantity" => quantity}, %{"accounts" => accounts}) do
    if has_enough_gold?(owner, quantity, accounts) do
      {
        :ok,
        %{"accounts" => transfer_gold(accounts, owner, to, quantity)}
      }
    else
      {:error, "You do not have enough gold to make the transfer"}
    end
  end

  def run_contract(owner, "amount", %{}, %{"accounts" => accounts}) do
    {:info, Map.get(accounts, owner, 0)}
  end

  defp has_enough_gold?(user, quantity, accounts) do
    Map.get(accounts, user, 0) >= quantity
  end

  defp transfer_gold(accounts, from, to, quantity) do
    from_amount = Map.get(accounts, from)
    to_amount = Map.get(accounts, to, 0)
    accounts
    |> Map.put(from, from_amount - quantity)
    |> Map.put(to, to_amount + quantity)
  end
end
