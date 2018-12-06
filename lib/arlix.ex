defmodule Arlix do
  @moduledoc """
  Documentation for Arlix.
  """

  @doc """
  Definition for ArWeave TX record

  """
  defmodule Tx do
    require Record
    Record.defrecord(:tx,  id: <<>>, last_tx: <<>>, owner: <<>>, tags: [], target: <<>>, quantity: 0, data: <<>>, signature: <<>>, reward: 0)

    @type tx :: record(:tx, id: String.t, last_tx: String.t, owner: String.t, tags: List.t, target: String.t, quantity: integer, data: binary(), signature: String.t, reward: integer)
  end
end
