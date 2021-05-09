defmodule Arlix do
  @moduledoc """
  Documentation for Arlix.
  """

  @doc """
  Definition for ArWeave TX record

  """
  defmodule Tx do
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
