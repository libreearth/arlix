defmodule Arlix do
  use Application
  @moduledoc """
  Documentation for Arlix.
  """

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      Arlix.Runtime.NodePool
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Arlix.Supervisor]
    Supervisor.start_link(children, opts)
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
