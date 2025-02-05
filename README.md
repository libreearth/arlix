# Arlix

An Elixir Smart Contract executor over Arweave with a cache for the contract state. The first step towards a verifiable computation framework.

## Usage
For the runtime to work you need to init the node with a name with the elixir --sname parameter
> iex --sname localname -S mix

Also an Elixir binary to be present in the computer is needed.



## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `arlix` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:arlix, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/arlix](https://hexdocs.pm/arlix).



## Arlix Contract format

The Arlix contract consists in a central Arweave transaction, where you can store binary data. This binary can be interpreted as the "phisical-digital" object related to the contract. 
The transaction has a initial state in json format and a reference to the other transaction where the Elixir code is as a binary.

The initial state is information described in json format, about the current state of the contract, for example, who is the owner of the digital content of the transaction. Any information described in json format is a valid contract state.


You can find an example of an Arlix contract in the following Arweave transaction: https://viewblock.io/arweave/tx/Bft911yTnCYq8S3iTK4X7hSFStEyZuhINk4GGfxxpy0


This example consist in a bank that initialy has 1000 coins owned by two users. The idea is to transfer thouse coins to other Arweave wallets. 
The initial state would be:


<strong>
{
    "accounts":{
      "pGfFMlk8bs_wFfvnYX3rQQUAXmBfvZMt50wroFTWPCixvqd6a0rVyh3EhMd2XYQMZ5fB1nYZduqfR6l3d4GX61MrL1cmTqaG6xsnjf7-YfOi03ussugVs0XbzqUHKJac8SyxrFzuU2sl0q2-cKep9NbjLcXWj-Bsux0BXTyhs5Y4kiPwAhV2yxl8EZRBKf6_qjVgcnyRc2wqFmA_PswDRUXfjrADY5jILZe9ngTePEdathGYjRgH2bYM93caFgWyUNo0vrvcGjg3WkpqMvtYz6SA6Xz0Z3r5kLQyC96Z90SwEqMb5IufzasJAckedJiFB7VPrwIk_t_yQUMEyukucnvFYfHD1-PnF3FfVRE5fbrsQyXF5gFR96q7KrBO1g8YBgwq1oa3Ui-g5n1zBln69SEuaH6Yo9TyJ0S3AL2ic7IU-tai5Zh6B05mdoq9pEzpjq8GZXSYqEmRsOsNUAwAevWv9hY65kMlegUtV3vfYKrrj7RxFDmhhJpY8utrAGcrIy9NVUrrJ_aCFoGjK7Kr3tWKqjuPbAlhpTp-W7zY05XvvgoHEgHlaBwCHQS1AWSXkY4gv1jF87jhgPfUPUzuBfCo8AKkED_su_Hjo3DQ5Lwv2ymrKF2aI2hFqF1OV63qkNgy5-NZVFPHz6Fu7uN7aLw_2nUXSKT0WF3ay3M0fx0":49,
      "xbVdoMCSWcgKssac3Mw_xvu2e-yR6PjmoES9X-ySTNT4DIajsLYkZ2QkG5CKng93Y-Eya-Q6S0-igJprPYoqQsNoYPXzHwJ3EGothQ3x2O6Taptv1LWRswexQUj1t0iyaspqA6PATSKugO60VgazvH-C5Dm4KjpbkQGkrWi2HCo9PYdPLYrGO_AUqdSHZUUSSrTk__VOkusvAJBMm3RqfiMFKxc07jT3oOerxhh7VteHb3q9XhKe62_DFKts237T0e1Gimcv7KfBDYXm_wp-gEC4q4fVBOuFibMm30Da-Y-fEMV8P3u2PDfmqNVGnOIwHSPmpaqNn_uystXZL9w1NbQLPC4fHz66yS9DIUtMPNtIlMMxUngs56oInntTE7zyop2RCLoSGIiKYWxiAVGwQy5Skk_94twlVmWYKuRHY1mb8IjrL9fB5DHjFdRsbx94-xq4TqU7xBNA47isFswREEIeUrX5p-sq8Uz-iaMiNiVLzYtysra8ZDMxp8BEoBN6wfctWQPKW3Di4vOLV0sb7iuF42RxEo7oN21d_7Thh5NtoBqxmEInQKoj_RxrYN9tuvaKKed8gMx-rVNVEFKgLGwcgUExX-0B9dpZqRaw8ZjJaQ6AF_3Qe86jTjmLDPopZ-UmhkMUli_3SHP8-CIpoeC4aft5VdCTFHD5K5NXuQ8":951}}</strong>
</strong>

## Arlix Contract Elixir Code

You can find the example of the last contract code in the following Arweave transaction. https://viewblock.io/arweave/tx/73qjRTcD_3Q8Yrhj8fa72gE9U2dxAYlHeDEwTPl0Idg

```elixir
defmodule ArlixContract do
  def run_contract(owner, "transfer", %{"to" => to, "quantity" => quantity}, %{
        "accounts" => accounts
      }) do
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
```

```output
{:module, ArlixContract, <<70, 79, 82, 49, 0, 0, 10, ...>>, {:transfer_gold, 4}}
```

The contract code describe how the initial state of the contract can be changed. When an Arweave user (with a wallet) wants to change the initial state he/she must call Arlix to execute the contract code. The method <code>run_contract/4</code> can do that.

The method run_contract/4 receives the wallet´s public key used to run the contract, the method to be executed, a map with the input parameters and the current state of the contract. 
The method must return <code>{:ok, state}</code> to change the state of the contract, <code>{:info, info}</code> if the state doesn´t change and only information is returned or <code>{:error, reason}</code> if an error happens or the call is incorrect

## Arlix Contract Action

Over a contract the user can create Actions. The actions are ammendments of the contract initial state generated using the contract code. All the possible ammendments are described in the contract Elixir code.

<!-- livebook:{"break_markdown":true} -->

The actions are stored in Arweave transactions. Here you can explore one: https://viewblock.io/arweave/tx/Gn18XUCr5O9itG7rXyqh8cm089axOOv1b2TUMzLdr-A

## Loading an Arlix contract

Arlix contract can be loaded using the id of the Arweave transaction that has the contract´s initial state

<code>
Arlix.create_node/1
</code>

```elixir
{:ok, pid} = Arlix.create_node("Bft911yTnCYq8S3iTK4X7hSFStEyZuhINk4GGfxxpy0")
```

```output
{:ok, #PID<0.866.0>}
```

The pid variable represents the contract and must be used in the following Arlix calls.


Arlix has now a copy of the contract in memory and will use it to minimize the access to the Arweave blockchain.

## Validate contract state

Once the contract is loaded in Arlix, may happen that another person changes the state of the contract addind an Action in the Arweave blockchain. To check that the state of the contract in memory is similar to the one in the blockchain we have <code>Arlix.ContractExecutor.validate_state/1</code>

```elixir
Arlix.ContractExecutor.validate_state(pid)
```

```output
true
```

If true then the state of the contract in memory is the same as the one of the blockchain. In case there is a discrepancy we can use <code>Arlix.ContractExecutor.move_to_last_contract_state/1</code> to update the state in memory with the information in the blockchain and make them match again.

```elixir
Arlix.ContractExecutor.move_to_last_contract_state(pid)
```

```output
%{
  "id" => "Bft911yTnCYq8S3iTK4X7hSFStEyZuhINk4GGfxxpy0",
  "last_action_id" => "22vKZ2gthlkK2H2qq5VjogMIEyQabkeNwRhcpYVG8Gs",
  "src" => "defmodule ArlixContract do\r\n  def run_contract(owner, \"transfer\", %{\"to\" => to, \"quantity\" => quantity}, %{\"accounts\" => accounts}) do\r\n    if has_enough_gold?(owner, quantity, accounts) do\r\n      {\r\n        :ok,\r\n        %{\"accounts\" => transfer_gold(accounts, owner, to, quantity)}\r\n      }\r\n    else\r\n      {:error, \"You do not have enough gold to make the transfer\"}\r\n    end\r\n  end\r\n\r\n  def run_contract(owner, \"amount\", %{}, %{\"accounts\" => accounts}) do\r\n    {:info, Map.get(accounts, owner, 0)}\r\n  end\r\n\r\n  defp has_enough_gold?(user, quantity, accounts) do\r\n    Map.get(accounts, user, 0) >= quantity\r\n  end\r\n\r\n  defp transfer_gold(accounts, from, to, quantity) do\r\n    from_amount = Map.get(accounts, from)\r\n    to_amount = Map.get(accounts, to, 0)\r\n    accounts\r\n    |> Map.put(from, from_amount - quantity)\r\n    |> Map.put(to, to_amount + quantity)\r\n  end\r\nend\r\n",
  "state" => %{
    "accounts" => %{
      "pGfFMlk8bs_wFfvnYX3rQQUAXmBfvZMt50wroFTWPCixvqd6a0rVyh3EhMd2XYQMZ5fB1nYZduqfR6l3d4GX61MrL1cmTqaG6xsnjf7-YfOi03ussugVs0XbzqUHKJac8SyxrFzuU2sl0q2-cKep9NbjLcXWj-Bsux0BXTyhs5Y4kiPwAhV2yxl8EZRBKf6_qjVgcnyRc2wqFmA_PswDRUXfjrADY5jILZe9ngTePEdathGYjRgH2bYM93caFgWyUNo0vrvcGjg3WkpqMvtYz6SA6Xz0Z3r5kLQyC96Z90SwEqMb5IufzasJAckedJiFB7VPrwIk_t_yQUMEyukucnvFYfHD1-PnF3FfVRE5fbrsQyXF5gFR96q7KrBO1g8YBgwq1oa3Ui-g5n1zBln69SEuaH6Yo9TyJ0S3AL2ic7IU-tai5Zh6B05mdoq9pEzpjq8GZXSYqEmRsOsNUAwAevWv9hY65kMlegUtV3vfYKrrj7RxFDmhhJpY8utrAGcrIy9NVUrrJ_aCFoGjK7Kr3tWKqjuPbAlhpTp-W7zY05XvvgoHEgHlaBwCHQS1AWSXkY4gv1jF87jhgPfUPUzuBfCo8AKkED_su_Hjo3DQ5Lwv2ymrKF2aI2hFqF1OV63qkNgy5-NZVFPHz6Fu7uN7aLw_2nUXSKT0WF3ay3M0fx0" => 49,
      "xbVdoMCSWcgKssac3Mw_xvu2e-yR6PjmoES9X-ySTNT4DIajsLYkZ2QkG5CKng93Y-Eya-Q6S0-igJprPYoqQsNoYPXzHwJ3EGothQ3x2O6Taptv1LWRswexQUj1t0iyaspqA6PATSKugO60VgazvH-C5Dm4KjpbkQGkrWi2HCo9PYdPLYrGO_AUqdSHZUUSSrTk__VOkusvAJBMm3RqfiMFKxc07jT3oOerxhh7VteHb3q9XhKe62_DFKts237T0e1Gimcv7KfBDYXm_wp-gEC4q4fVBOuFibMm30Da-Y-fEMV8P3u2PDfmqNVGnOIwHSPmpaqNn_uystXZL9w1NbQLPC4fHz66yS9DIUtMPNtIlMMxUngs56oInntTE7zyop2RCLoSGIiKYWxiAVGwQy5Skk_94twlVmWYKuRHY1mb8IjrL9fB5DHjFdRsbx94-xq4TqU7xBNA47isFswREEIeUrX5p-sq8Uz-iaMiNiVLzYtysra8ZDMxp8BEoBN6wfctWQPKW3Di4vOLV0sb7iuF42RxEo7oN21d_7Thh5NtoBqxmEInQKoj_RxrYN9tuvaKKed8gMx-rVNVEFKgLGwcgUExX-0B9dpZqRaw8ZjJaQ6AF_3Qe86jTjmLDPopZ-UmhkMUli_3SHP8-CIpoeC4aft5VdCTFHD5K5NXuQ8" => 951
    }
  }
}
```

The function returns a map with information about the updated contract state

## Running a contract

We can run a contract method with the function <code>Arlix.ContractExecutor.execute_contract/4.</code> This function executes the contract but only returns the result of the action, but doesn't save it on the blockchain.

```elixir
public_key_of_the_owner =
  "pGfFMlk8bs_wFfvnYX3rQQUAXmBfvZMt50wroFTWPCixvqd6a0rVyh3EhMd2XYQMZ5fB1nYZduqfR6l3d4GX61MrL1cmTqaG6xsnjf7-YfOi03ussugVs0XbzqUHKJac8SyxrFzuU2sl0q2-cKep9NbjLcXWj-Bsux0BXTyhs5Y4kiPwAhV2yxl8EZRBKf6_qjVgcnyRc2wqFmA_PswDRUXfjrADY5jILZe9ngTePEdathGYjRgH2bYM93caFgWyUNo0vrvcGjg3WkpqMvtYz6SA6Xz0Z3r5kLQyC96Z90SwEqMb5IufzasJAckedJiFB7VPrwIk_t_yQUMEyukucnvFYfHD1-PnF3FfVRE5fbrsQyXF5gFR96q7KrBO1g8YBgwq1oa3Ui-g5n1zBln69SEuaH6Yo9TyJ0S3AL2ic7IU-tai5Zh6B05mdoq9pEzpjq8GZXSYqEmRsOsNUAwAevWv9hY65kMlegUtV3vfYKrrj7RxFDmhhJpY8utrAGcrIy9NVUrrJ_aCFoGjK7Kr3tWKqjuPbAlhpTp-W7zY05XvvgoHEgHlaBwCHQS1AWSXkY4gv1jF87jhgPfUPUzuBfCo8AKkED_su_Hjo3DQ5Lwv2ymrKF2aI2hFqF1OV63qkNgy5-NZVFPHz6Fu7uN7aLw_2nUXSKT0WF3ay3M0fx0"

Arlix.ContractExecutor.execute_contract(pid, public_key_of_the_owner, "amount", %{})
```

```output
{:info, 49}
```

In this case the execution returns information.

It´s ok using directly any public key as this function only is used as a test, just to explore what the contract can do and the result of any execution.

Sometimes what we want is to update the contract, for example, lets say that someone wants to transfer to another wallet a coin. This means the state of the contract must change. In this case is not enough to run the contract, we must run it and then save it. To save the contract is not enough with the public key, but the whole wallet. Any saved operation in the blockchain must be signed with the private key of the person that changes the contract state.


To change the contract state we must load the Arweave wallet.

```elixir
wallet = File.read!(wallet_file_path) |> Arlix.Wallet.from_json()
"Secret!!"
```

```output
"Secret!!"
```

Now we have the wallet and we can call the contract, but this time we will use the function <code>Arlix.ContractExecutor.update_transaction/4.</code> This function not only executes the contract, but also store the result in a Arweave transaction as an Arlix Action

```elixir
input = %{
  "to" =>
    "pGfFMlk8bs_wFfvnYX3rQQUAXmBfvZMt50wroFTWPCixvqd6a0rVyh3EhMd2XYQMZ5fB1nYZduqfR6l3d4GX61MrL1cmTqaG6xsnjf7-YfOi03ussugVs0XbzqUHKJac8SyxrFzuU2sl0q2-cKep9NbjLcXWj-Bsux0BXTyhs5Y4kiPwAhV2yxl8EZRBKf6_qjVgcnyRc2wqFmA_PswDRUXfjrADY5jILZe9ngTePEdathGYjRgH2bYM93caFgWyUNo0vrvcGjg3WkpqMvtYz6SA6Xz0Z3r5kLQyC96Z90SwEqMb5IufzasJAckedJiFB7VPrwIk_t_yQUMEyukucnvFYfHD1-PnF3FfVRE5fbrsQyXF5gFR96q7KrBO1g8YBgwq1oa3Ui-g5n1zBln69SEuaH6Yo9TyJ0S3AL2ic7IU-tai5Zh6B05mdoq9pEzpjq8GZXSYqEmRsOsNUAwAevWv9hY65kMlegUtV3vfYKrrj7RxFDmhhJpY8utrAGcrIy9NVUrrJ_aCFoGjK7Kr3tWKqjuPbAlhpTp-W7zY05XvvgoHEgHlaBwCHQS1AWSXkY4gv1jF87jhgPfUPUzuBfCo8AKkED_su_Hjo3DQ5Lwv2ymrKF2aI2hFqF1OV63qkNgy5-NZVFPHz6Fu7uN7aL
w_2nUXSKT0WF3ay3M0fx0",
  "quantity" => 1
}

Arlix.ContractExecutor.update_transaction(pid, wallet, input, "transfer")
```

```output
%{
  "data" => "eyJhY2NvdW50cyI6eyJwR2ZGTWxrOGJzX3dGZnZuWVgzclFRVUFYbUJmdlpNdDUwd3JvRlRXUENpeHZxZDZhMHJWeWgzRWhNZDJYWVFNWjVmQjFuWVpkdXFmUjZsM2Q0R1g2MU1yTDFjbVRxYUc2eHNuamY3LVlmT2kwM3Vzc3VnVnMwWGJ6cVVIS0phYzhTeXhyRnp1VTJzbDBxMi1jS2VwOU5iakxjWFdqLUJzdXgwQlhUeWhzNVk0a2lQd0FoVjJ5eGw4RVpSQktmNl9xalZnY255UmMyd3FGbUFfUHN3RFJVWGZqckFEWTVqSUxaZTluZ1RlUEVkYXRoR1lqUmdIMmJZTTkzY2FGZ1d5VU5vMHZydmNHamczV2twcU12dFl6NlNBNlh6MFozcjVrTFF5Qzk2WjkwU3dFcU1iNUl1Znphc0pBY2tlZEppRkI3VlByd0lrX3RfeVFVTUV5dWt1Y252RllmSEQxLVBuRjNGZlZSRTVmYnJzUXlYRjVnRlI5NnE3S3JCTzFnOFlCZ3dxMW9hM1VpLWc1bjF6QmxuNjlTRXVhSDZZbzlUeUowUzNBTDJpYzdJVS10YWk1Wmg2QjA1bWRvcTlwRXpwanE4R1pYU1lxRW1Sc09zTlVBd0Fldld2OWhZNjVrTWxlZ1V0VjN2ZllLcnJqN1J4RkRtaGhKcFk4dXRyQUdjckl5OU5WVXJySl9hQ0ZvR2pLN0tyM3RXS3FqdVBiQWxocFRwLVc3elkwNVh2dmdvSEVnSGxhQndDSFFTMUFXU1hrWTRndjFqRjg3amhnUGZVUFV6dUJmQ284QUtrRURfc3VfSGpvM0RRNUx3djJ5bXJLRjJhSTJoRnFGMU9WNjNxa05neTUtTlpWRlBIejZGdTd1TjdhTFxyXG53XzJuVVhTS1QwV0YzYXkzTTBmeDAiOjEsInBHZkZNbGs4YnNfd0Zmdm5ZWDNyUVFVQVhtQmZ2Wk10NTB3cm9GVFdQQ2l4dnFkNmEwclZ5aDNFaE1kMlhZUU1aNWZCMW5ZWmR1cWZSNmwzZDRHWDYxTXJMMWNtVHFhRzZ4c25qZjctWWZPaTAzdXNzdWdWczBYYnpxVUhLSmFjOFN5eHJGenVVMnNsMHEyLWNLZXA5TmJqTGNYV2otQnN1eDBCWFR5aHM1WTRraVB3QWhWMnl4bDhFWlJCS2Y2X3FqVmdjbnlSYzJ3cUZtQV9Qc3dEUlVYZmpyQURZNWpJTFplOW5nVGVQRWRhdGhHWWpSZ0gyYllNOTNjYUZnV3lVTm8wdnJ2Y0dqZzNXa3BxTXZ0WXo2U0E2WHowWjNyNWtMUXlDOTZaOTBTd0VxTWI1SXVmemFzSkFja2VkSmlGQjdWUHJ3SWtfdF95UVVNRXl1a3VjbnZGWWZIRDEtUG5GM0ZmVlJFNWZicnNReVhGNWdGUjk2cTdLckJPMWc4WUJnd3Exb2EzVWktZzVuMXpCbG42OVNFdWFINllvOVR5SjBTM0FMMmljN0lVLXRhaTVaaDZCMDVtZG9xOXBFenBqcThHWlhTWXFFbVJzT3NOVUF3QWV2V3Y5aFk2NWtNbGVnVXRWM3ZmWUtycmo3UnhGRG1oaEpwWTh1dHJBR2NySXk5TlZVcnJKX2FDRm9Haks3S3IzdFdLcWp1UGJBbGhwVHAtVzd6WTA1WHZ2Z29IRWdIbGFCd0NIUVMxQVdTWGtZNGd2MWpGODdqaGdQZlVQVXp1QmZDbzhBS2tFRF9zdV9Iam8zRFE1THd2MnltcktGMmFJMmhGcUYxT1Y2M3FrTmd5NS1OWlZGUEh6NkZ1N3VON2FMd18yblVYU0tUMFdGM2F5M00wZngwIjo0OSwieGJWZG9NQ1NXY2dLc3NhYzNNd194dnUyZS15UjZQam1vRVM5WC15U1ROVDRESWFqc0xZa1oyUWtHNUNLbmc5M1ktRXlhLVE2UzAtaWdKcHJQWW9xUXNOb1lQWHpId0ozRUdvdGhRM3gyTzZUYXB0djFMV1Jzd2V4UVVqMXQwaXlhc3BxQTZQQVRTS3VnTzYwVmdhenZILUM1RG00S2pwYmtRR2tyV2kySENvOVBZZFBMWXJHT19BVXFkU0haVVVTU3JUa19fVk9rdXN2QUpCTW0zUnFmaU1GS3hjMDdqVDNvT2VyeGhoN1Z0ZUhiM3E5WGhLZTYyX0RGS3RzMjM3VDBlMUdpbWN2N0tmQkRZWG1fd3AtZ0VDNHE0ZlZCT3VGaWJNbTMwRGEtWS1mRU1WOFAzdTJQRGZtcU5WR25PSXdIU1BtcGFxTm5fdXlzdFhaTDl3MU5iUUxQQzRmSHo2NnlTOURJVXRNUE50SWxNTXhVbmdzNTZvSW5udFRFN3p5b3AyUkNMb1NHSWlLWVd4aUFWR3dReTVTa2tfOTR0d2xWbVdZS3VSSFkxbWI4SWpyTDlmQjVESGpGZFJzYng5NC14cTRUcVU3eEJOQTQ3aXNGc3dSRUVJZVVyWDVwLXNxOFV6LWlhTWlOaVZMell0eXNyYThaRE14cDhCRW9CTjZ3ZmN0V1FQS1czRGk0dk9MVjBzYjdpdUY0MlJ4RW83b04yMWRfN1RoaDVOdG9CcXhtRUluUUtval9SeHJZTjl0dXZhS0tlZDhnTXgtclZOVkVGS2dMR3djZ1VFeFgtMEI5ZHBacVJhdzhaakphUTZBRl8zUWU4NmpUam1MRFBvcFotVW1oa01VbGlfM1NIUDgtQ0lwb2VDNGFmdDVWZENURkhENUs1Tlh1UTgiOjk1MH19",
  "data_root" => "",
  "data_size" => "2085",
  "data_tree" => [],
  "format" => 1,
  "id" => "4XL0cKZCyffzzyhbpFoO1YBUFbcUhk941JXiKAIxrhg",
  "last_tx" => "22vKZ2gthlkK2H2qq5VjogMIEyQabkeNwRhcpYVG8Gs",
  "owner" => "xbVdoMCSWcgKssac3Mw_xvu2e-yR6PjmoES9X-ySTNT4DIajsLYkZ2QkG5CKng93Y-Eya-Q6S0-igJprPYoqQsNoYPXzHwJ3EGothQ3x2O6Taptv1LWRswexQUj1t0iyaspqA6PATSKugO60VgazvH-C5Dm4KjpbkQGkrWi2HCo9PYdPLYrGO_AUqdSHZUUSSrTk__VOkusvAJBMm3RqfiMFKxc07jT3oOerxhh7VteHb3q9XhKe62_DFKts237T0e1Gimcv7KfBDYXm_wp-gEC4q4fVBOuFibMm30Da-Y-fEMV8P3u2PDfmqNVGnOIwHSPmpaqNn_uystXZL9w1NbQLPC4fHz66yS9DIUtMPNtIlMMxUngs56oInntTE7zyop2RCLoSGIiKYWxiAVGwQy5Skk_94twlVmWYKuRHY1mb8IjrL9fB5DHjFdRsbx94-xq4TqU7xBNA47isFswREEIeUrX5p-sq8Uz-iaMiNiVLzYtysra8ZDMxp8BEoBN6wfctWQPKW3Di4vOLV0sb7iuF42RxEo7oN21d_7Thh5NtoBqxmEInQKoj_RxrYN9tuvaKKed8gMx-rVNVEFKgLGwcgUExX-0B9dpZqRaw8ZjJaQ6AF_3Qe86jTjmLDPopZ-UmhkMUli_3SHP8-CIpoeC4aft5VdCTFHD5K5NXuQ8",
  "quantity" => "0",
  "reward" => "2567016",
  "signature" => "PfKA6vqbVIxv5xomhIfPJT9nSqlEAad9ONjjXGyT0XGwruUeGk8pqgaTTKnJyGueQVWAwVWwCE7W8VhXhNUrgtMCi7FTtN_p_HxgvVfv0xSEFcERquMbAAxssKU0ieTx_IWcf77ENL2dgTif7XfaMzBSqTLFpr375zpOmjn7cxGPlqe-_rw5NDzWi36GiM-Q0Mgkc567cMqtfADUJlPAr7SHoUzTfEYqstp-rjbV9S7DecLUISxFfFWoXSMfjf7a_TyEL9yJkRw0siUREjF33Mz37pm5Xmtto0fdedsgq1gsNDWvmRpMXIrdxmAHTV1A3w_rpXNoeoEURTQB6w5RasLvzCO8VUKEeE4qEjVP18Tni-sRPWBIVWo2BTyz_5Pf-Sv7YzPJZoW10lL-ahllqk9SxzS6fKmuLgsvHQY1_vf14uyggPFWG64XmF6Jjl7kHvAV0oSUTVlDHT61MrwxCodryTnR4_LNt02Y9QCeMWmmPLLslDT_RO_hA4n-iVqSPtGAVUbU9b4AR6RKdi5Yydu4WSL0kziGi5cUVXvnxgltL4VoQLmIUlN48yd_bfTbEuf8ubfpdROVXgyOUBVeX31z5TpC5rVIwWATVTPgWT69Sb-arBMPFSwPX7FNVd10CzeqUDz6ZQ2QgNW2TtM94bVtjrKjKLrR-YcraNgDwLY",
  "tags" => [
    %{"name" => "Q29udGVudC1UeXBl", "value" => "YXBwbGljYXRpb24vanNvbg"},
    %{"name" => "QXBwLU5hbWU", "value" => "QXJsaXgtdGVzdC1jb250cmFjdA"},
    %{"name" => "QXBwLVZlcnNpb24", "value" => "MC4wLjE"},
    %{
      "name" => "Q29udHJhY3Q",
      "value" => "QmZ0OTExeVRuQ1lxOFMzaVRLNFg3aFNGU3RFeVp1aElOazRHR2Z4eHB5MA"
    },
    %{
      "name" => "SW5wdXQ",
      "value" => "eyJxdWFudGl0eSI6MSwidG8iOiJwR2ZGTWxrOGJzX3dGZnZuWVgzclFRVUFYbUJmdlpNdDUwd3JvRlRXUENpeHZxZDZhMHJWeWgzRWhNZDJYWVFNWjVmQjFuWVpkdXFmUjZsM2Q0R1g2MU1yTDFjbVRxYUc2eHNuamY3LVlmT2kwM3Vzc3VnVnMwWGJ6cVVIS0phYzhTeXhyRnp1VTJzbDBxMi1jS2VwOU5iakxjWFdqLUJzdXgwQlhUeWhzNVk0a2lQd0FoVjJ5eGw4RVpSQktmNl9xalZnY255UmMyd3FGbUFfUHN3RFJVWGZqckFEWTVqSUxaZTluZ1RlUEVkYXRoR1lqUmdIMmJZTTkzY2FGZ1d5VU5vMHZydmNHamczV2twcU12dFl6NlNBNlh6MFozcjVrTFF5Qzk2WjkwU3dFcU1iNUl1Znphc0pBY2tlZEppRkI3VlByd0lrX3RfeVFVTUV5dWt1Y252RllmSEQxLVBuRjNGZlZSRTVmYnJzUXlYRjVnRlI5NnE3S3JCTzFnOFlCZ3dxMW9hM1VpLWc1bjF6QmxuNjlTRXVhSDZZbzlUeUowUzNBTDJpYzdJVS10YWk1Wmg2QjA1bWRvcTlwRXpwanE4R1pYU1lxRW1Sc09zTlVBd0Fldld2OWhZNjVrTWxlZ1V0VjN2ZllLcnJqN1J4RkRtaGhKcFk4dXRyQUdjckl5OU5WVXJySl9hQ0ZvR2pLN0tyM3RXS3FqdVBiQWxocFRwLVc3elkwNVh2dmdvSEVnSGxhQndDSFFTMUFXU1hrWTRndjFqRjg3amhnUGZVUFV6dUJmQ284QUtrRURfc3VfSGpvM0RRNUx3djJ5bXJLRjJhSTJoRnFGMU9WNjNxa05neTUtTlpWRlBIejZGdTd1TjdhTFxyXG53XzJuVVhTS1QwV0YzYXkzTTBmeDAifQ"
    },
    %{"name" => "TWV0aG9k", "value" => "dHJhbnNmZXI"}
  ],
  "target" => ""
}
```

We can see the execution has returned a map describing the arlix transaction, this are good news, it means the transaction has been sent to the Arweave network and soon a gentle miner will write it down to the blockchain. Anyway Arlix is aware that the transaction has been done, so you don't have to wait for the miners to complete the job. You can alredy see the new state.

```elixir
Arlix.ContractExecutor.get_state(pid)
```

```output
%{
  "id" => "Bft911yTnCYq8S3iTK4X7hSFStEyZuhINk4GGfxxpy0",
  "last_action_id" => "4XL0cKZCyffzzyhbpFoO1YBUFbcUhk941JXiKAIxrhg",
  "src" => "defmodule ArlixContract do\r\n  def run_contract(owner, \"transfer\", %{\"to\" => to, \"quantity\" => quantity}, %{\"accounts\" => accounts}) do\r\n    if has_enough_gold?(owner, quantity, accounts) do\r\n      {\r\n        :ok,\r\n        %{\"accounts\" => transfer_gold(accounts, owner, to, quantity)}\r\n      }\r\n    else\r\n      {:error, \"You do not have enough gold to make the transfer\"}\r\n    end\r\n  end\r\n\r\n  def run_contract(owner, \"amount\", %{}, %{\"accounts\" => accounts}) do\r\n    {:info, Map.get(accounts, owner, 0)}\r\n  end\r\n\r\n  defp has_enough_gold?(user, quantity, accounts) do\r\n    Map.get(accounts, user, 0) >= quantity\r\n  end\r\n\r\n  defp transfer_gold(accounts, from, to, quantity) do\r\n    from_amount = Map.get(accounts, from)\r\n    to_amount = Map.get(accounts, to, 0)\r\n    accounts\r\n    |> Map.put(from, from_amount - quantity)\r\n    |> Map.put(to, to_amount + quantity)\r\n  end\r\nend\r\n",
  "state" => %{
    "accounts" => %{
      "pGfFMlk8bs_wFfvnYX3rQQUAXmBfvZMt50wroFTWPCixvqd6a0rVyh3EhMd2XYQMZ5fB1nYZduqfR6l3d4GX61MrL1cmTqaG6xsnjf7-YfOi03ussugVs0XbzqUHKJac8SyxrFzuU2sl0q2-cKep9NbjLcXWj-Bsux0BXTyhs5Y4kiPwAhV2yxl8EZRBKf6_qjVgcnyRc2wqFmA_PswDRUXfjrADY5jILZe9ngTePEdathGYjRgH2bYM93caFgWyUNo0vrvcGjg3WkpqMvtYz6SA6Xz0Z3r5kLQyC96Z90SwEqMb5IufzasJAckedJiFB7VPrwIk_t_yQUMEyukucnvFYfHD1-PnF3FfVRE5fbrsQyXF5gFR96q7KrBO1g8YBgwq1oa3Ui-g5n1zBln69SEuaH6Yo9TyJ0S3AL2ic7IU-tai5Zh6B05mdoq9pEzpjq8GZXSYqEmRsOsNUAwAevWv9hY65kMlegUtV3vfYKrrj7RxFDmhhJpY8utrAGcrIy9NVUrrJ_aCFoGjK7Kr3tWKqjuPbAlhpTp-W7zY05XvvgoHEgHlaBwCHQS1AWSXkY4gv1jF87jhgPfUPUzuBfCo8AKkED_su_Hjo3DQ5Lwv2ymrKF2aI2hFqF1OV63qkNgy5-NZVFPHz6Fu7uN7aL\r\nw_2nUXSKT0WF3ay3M0fx0" => 1,
      "pGfFMlk8bs_wFfvnYX3rQQUAXmBfvZMt50wroFTWPCixvqd6a0rVyh3EhMd2XYQMZ5fB1nYZduqfR6l3d4GX61MrL1cmTqaG6xsnjf7-YfOi03ussugVs0XbzqUHKJac8SyxrFzuU2sl0q2-cKep9NbjLcXWj-Bsux0BXTyhs5Y4kiPwAhV2yxl8EZRBKf6_qjVgcnyRc2wqFmA_PswDRUXfjrADY5jILZe9ngTePEdathGYjRgH2bYM93caFgWyUNo0vrvcGjg3WkpqMvtYz6SA6Xz0Z3r5kLQyC96Z90SwEqMb5IufzasJAckedJiFB7VPrwIk_t_yQUMEyukucnvFYfHD1-PnF3FfVRE5fbrsQyXF5gFR96q7KrBO1g8YBgwq1oa3Ui-g5n1zBln69SEuaH6Yo9TyJ0S3AL2ic7IU-tai5Zh6B05mdoq9pEzpjq8GZXSYqEmRsOsNUAwAevWv9hY65kMlegUtV3vfYKrrj7RxFDmhhJpY8utrAGcrIy9NVUrrJ_aCFoGjK7Kr3tWKqjuPbAlhpTp-W7zY05XvvgoHEgHlaBwCHQS1AWSXkY4gv1jF87jhgPfUPUzuBfCo8AKkED_su_Hjo3DQ5Lwv2ymrKF2aI2hFqF1OV63qkNgy5-NZVFPHz6Fu7uN7aLw_2nUXSKT0WF3ay3M0fx0" => 49,
      "xbVdoMCSWcgKssac3Mw_xvu2e-yR6PjmoES9X-ySTNT4DIajsLYkZ2QkG5CKng93Y-Eya-Q6S0-igJprPYoqQsNoYPXzHwJ3EGothQ3x2O6Taptv1LWRswexQUj1t0iyaspqA6PATSKugO60VgazvH-C5Dm4KjpbkQGkrWi2HCo9PYdPLYrGO_AUqdSHZUUSSrTk__VOkusvAJBMm3RqfiMFKxc07jT3oOerxhh7VteHb3q9XhKe62_DFKts237T0e1Gimcv7KfBDYXm_wp-gEC4q4fVBOuFibMm30Da-Y-fEMV8P3u2PDfmqNVGnOIwHSPmpaqNn_uystXZL9w1NbQLPC4fHz66yS9DIUtMPNtIlMMxUngs56oInntTE7zyop2RCLoSGIiKYWxiAVGwQy5Skk_94twlVmWYKuRHY1mb8IjrL9fB5DHjFdRsbx94-xq4TqU7xBNA47isFswREEIeUrX5p-sq8Uz-iaMiNiVLzYtysra8ZDMxp8BEoBN6wfctWQPKW3Di4vOLV0sb7iuF42RxEo7oN21d_7Thh5NtoBqxmEInQKoj_RxrYN9tuvaKKed8gMx-rVNVEFKgLGwcgUExX-0B9dpZqRaw8ZjJaQ6AF_3Qe86jTjmLDPopZ-UmhkMUli_3SHP8-CIpoeC4aft5VdCTFHD5K5NXuQ8" => 950
    }
  }
}
```

We can see then contract has been already executed.

<!-- livebook:{"break_markdown":true} -->

Sadly if we check if the contract has the same information than the blockchain we can see that´s not the case.

```elixir
Arlix.ContractExecutor.validate_state(pid)
```

```output
false
```

It doesn´t matter, it is a temporal situation, as soon as a miner writes down the transaction to the blockchain the check will succeed. But thanks to Arlix we have already our new state in memory, so we can work with it even if the transaction is not completed.

```elixir
public_key_of_the_owner =
  "pGfFMlk8bs_wFfvnYX3rQQUAXmBfvZMt50wroFTWPCixvqd6a0rVyh3EhMd2XYQMZ5fB1nYZduqfR6l3d4GX61MrL1cmTqaG6xsnjf7-YfOi03ussugVs0XbzqUHKJac8SyxrFzuU2sl0q2-cKep9NbjLcXWj-Bsux0BXTyhs5Y4kiPwAhV2yxl8EZRBKf6_qjVgcnyRc2wqFmA_PswDRUXfjrADY5jILZe9ngTePEdathGYjRgH2bYM93caFgWyUNo0vrvcGjg3WkpqMvtYz6SA6Xz0Z3r5kLQyC96Z90SwEqMb5IufzasJAckedJiFB7VPrwIk_t_yQUMEyukucnvFYfHD1-PnF3FfVRE5fbrsQyXF5gFR96q7KrBO1g8YBgwq1oa3Ui-g5n1zBln69SEuaH6Yo9TyJ0S3AL2ic7IU-tai5Zh6B05mdoq9pEzpjq8GZXSYqEmRsOsNUAwAevWv9hY65kMlegUtV3vfYKrrj7RxFDmhhJpY8utrAGcrIy9NVUrrJ_aCFoGjK7Kr3tWKqjuPbAlhpTp-W7zY05XvvgoHEgHlaBwCHQS1AWSXkY4gv1jF87jhgPfUPUzuBfCo8AKkED_su_Hjo3DQ5Lwv2ymrKF2aI2hFqF1OV63qkNgy5-NZVFPHz6Fu7uN7aLw_2nUXSKT0WF3ay3M0fx0"

Arlix.ContractExecutor.execute_contract(pid, public_key_of_the_owner, "amount", %{})
```

```output
{:info, 49}
```

We can check how the transaction is going, we have the transaction id in "last_action_id" field of the contract state.

```elixir
Arlix.HttpApi.transaction_status!("4XL0cKZCyffzzyhbpFoO1YBUFbcUhk941JXiKAIxrhg")
```

```output
"Pending"
```

We´ll just wait for 10... 20... 30 minutes and ... voila!!

```elixir
Arlix.HttpApi.transaction_status!("4XL0cKZCyffzzyhbpFoO1YBUFbcUhk941JXiKAIxrhg")
```

```output
"{\"block_height\":747940,\"block_indep_hash\":\"V8Q2xzrTHMDRCqNgUwpQZfbDFa6qZQ9BPDPDFO7lHpiJ7vrj5f9DVDpsSFmzB-_P\",\"number_of_confirmations\":4}"
```

The transaction is in the block so... now we can check if Arlix is sinchronized.

```elixir
Arlix.ContractExecutor.validate_state(pid)
```

```output
true
```

This is so nice... :)

## Creating a new Arlix Contract

Arlix comes with several modules to interact with Arlix contracts in a functional way. Please visit the Arlix.Contract module documentation of the library so you can explore the different options.

The most interesting option is the capability of creating new contracts. To create a new Contract first we need to upload the source code of the contract and load it as a string.
Also we need a map with the initial estate of the contract.

After that use the <code>Arlix.Contract.upload_contract_src/3</code> and <code>Arlix.Contract.upload_contract_init_data/6</code> as shown behind:

```elixir
code = """
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
"""

initial_map = %{
  "accounts" => %{
    "pGfFMlk8bs_wFfvnYX3rQQUAXmBfvZMt50wroFTWPCixvqd6a0rVyh3EhMd2XYQMZ5fB1nYZduqfR6l3d4GX61MrL1cmTqaG6xsnjf7-YfOi03ussugVs0XbzqUHKJac8SyxrFzuU2sl0q2-cKep9NbjLcXWj-Bsux0BXTyhs5Y4kiPwAhV2yxl8EZRBKf6_qjVgcnyRc2wqFmA_PswDRUXfjrADY5jILZe9ngTePEdathGYjRgH2bYM93caFgWyUNo0vrvcGjg3WkpqMvtYz6SA6Xz0Z3r5kLQyC96Z90SwEqMb5IufzasJAckedJiFB7VPrwIk_t_yQUMEyukucnvFYfHD1-PnF3FfVRE5fbrsQyXF5gFR96q7KrBO1g8YBgwq1oa3Ui-g5n1zBln69SEuaH6Yo9TyJ0S3AL2ic7IU-tai5Zh6B05mdoq9pEzpjq8GZXSYqEmRsOsNUAwAevWv9hY65kMlegUtV3vfYKrrj7RxFDmhhJpY8utrAGcrIy9NVUrrJ_aCFoGjK7Kr3tWKqjuPbAlhpTp-W7zY05XvvgoHEgHlaBwCHQS1AWSXkY4gv1jF87jhgPfUPUzuBfCo8AKkED_su_Hjo3DQ5Lwv2ymrKF2aI2hFqF1OV63qkNgy5-NZVFPHz6Fu7uN7aL\r\nw_2nUXSKT0WF3ay3M0fx0" =>
      1,
    "pGfFMlk8bs_wFfvnYX3rQQUAXmBfvZMt50wroFTWPCixvqd6a0rVyh3EhMd2XYQMZ5fB1nYZduqfR6l3d4GX61MrL1cmTqaG6xsnjf7-YfOi03ussugVs0XbzqUHKJac8SyxrFzuU2sl0q2-cKep9NbjLcXWj-Bsux0BXTyhs5Y4kiPwAhV2yxl8EZRBKf6_qjVgcnyRc2wqFmA_PswDRUXfjrADY5jILZe9ngTePEdathGYjRgH2bYM93caFgWyUNo0vrvcGjg3WkpqMvtYz6SA6Xz0Z3r5kLQyC96Z90SwEqMb5IufzasJAckedJiFB7VPrwIk_t_yQUMEyukucnvFYfHD1-PnF3FfVRE5fbrsQyXF5gFR96q7KrBO1g8YBgwq1oa3Ui-g5n1zBln69SEuaH6Yo9TyJ0S3AL2ic7IU-tai5Zh6B05mdoq9pEzpjq8GZXSYqEmRsOsNUAwAevWv9hY65kMlegUtV3vfYKrrj7RxFDmhhJpY8utrAGcrIy9NVUrrJ_aCFoGjK7Kr3tWKqjuPbAlhpTp-W7zY05XvvgoHEgHlaBwCHQS1AWSXkY4gv1jF87jhgPfUPUzuBfCo8AKkED_su_Hjo3DQ5Lwv2ymrKF2aI2hFqF1OV63qkNgy5-NZVFPHz6Fu7uN7aLw_2nUXSKT0WF3ay3M0fx0" =>
      49,
    "xbVdoMCSWcgKssac3Mw_xvu2e-yR6PjmoES9X-ySTNT4DIajsLYkZ2QkG5CKng93Y-Eya-Q6S0-igJprPYoqQsNoYPXzHwJ3EGothQ3x2O6Taptv1LWRswexQUj1t0iyaspqA6PATSKugO60VgazvH-C5Dm4KjpbkQGkrWi2HCo9PYdPLYrGO_AUqdSHZUUSSrTk__VOkusvAJBMm3RqfiMFKxc07jT3oOerxhh7VteHb3q9XhKe62_DFKts237T0e1Gimcv7KfBDYXm_wp-gEC4q4fVBOuFibMm30Da-Y-fEMV8P3u2PDfmqNVGnOIwHSPmpaqNn_uystXZL9w1NbQLPC4fHz66yS9DIUtMPNtIlMMxUngs56oInntTE7zyop2RCLoSGIiKYWxiAVGwQy5Skk_94twlVmWYKuRHY1mb8IjrL9fB5DHjFdRsbx94-xq4TqU7xBNA47isFswREEIeUrX5p-sq8Uz-iaMiNiVLzYtysra8ZDMxp8BEoBN6wfctWQPKW3Di4vOLV0sb7iuF42RxEo7oN21d_7Thh5NtoBqxmEInQKoj_RxrYN9tuvaKKed8gMx-rVNVEFKgLGwcgUExX-0B9dpZqRaw8ZjJaQ6AF_3Qe86jTjmLDPopZ-UmhkMUli_3SHP8-CIpoeC4aft5VdCTFHD5K5NXuQ8" =>
      950
  }
}

data = "Whatever data you want to store in the contract, a string, music, a picture..."
data_content_type = "text/html"
{:ok, src_tx_id} = Arlix.Contract.upload_contract_src(code, wallet)
Arlix.Contract.upload_contract_init_data(data, data_content_type, initial_map, src_tx_id, wallet)
```

When the two transactions are persisted in the blockchain you have a alive Arlix contract!!

## Http Arweave Api Module

Arlix includes a library to interact with the Http Arweave inteface, so feel free to explore the Arlix.HttpApi module if you just want to use Arweave in other different and fun ways!

