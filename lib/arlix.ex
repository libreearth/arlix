defmodule Arlix do
  use Application
  @moduledoc """
  Documentation for Arlix.
  """

  alias Arlix.ContractExecutor
  alias Arlix.TransactionSaver
  alias Arlix.Contract

  def start(_type, _args) do
    import Supervisor.Spec, warn: false


    # Define workers and child supervisors to be supervised
    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: Arlix.DynamicSupervisor}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  @doc """
  Creates an arlix node to rembember the state of a contract
  """
  def create_node(contract_id) do
    case Contract.load_contract(contract_id) do
      {:ok, contract} ->
        case DynamicSupervisor.start_child(Arlix.DynamicSupervisor, {TransactionSaver, []}) do
          {:ok, saver_pid} -> DynamicSupervisor.start_child(Arlix.DynamicSupervisor, {ContractExecutor, {contract_id, contract, saver_pid}})
          error -> error
        end
      error -> error
    end
  end


  defmodule Tx do
    @moduledoc """
    Definition for ArWeave TX record
    """
    require Record

    Record.defrecord(:tx,
      format: 1,
      id: <<>>,
      last_tx: <<>>,
      owner: <<>>,
      tags: [],
      target: <<>>,
      quantity: 0,
      data: <<>>,
      data_size: 0,
      data_tree: [],
      data_root: <<>>,
      signature: <<>>,
      reward: 0)


    @type tx :: record(:tx,
      format: integer,
      id: String.t,
      last_tx: String.t,
      owner: String.t,
      tags: List.t,
      target: String.t,
      quantity: integer,
      data: binary(),
      data_size: integer,
      data_tree: List.t,
      data_root: String.t,
      signature: String.t,
      reward: integer)
  end
end
