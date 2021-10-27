defmodule Chunks do
  @doc """
  Data tree node of the v2 transactions to elixir map
    # id,
	  # type = branch, % root | branch | leaf
	  # data, % The value (for leaves)
	  # note, % A number less than 2^256
	  # left, % The (optional) ID of a node to the left
	  # right, % The (optional) ID of a node to the right
	  # max % The maximum observed note at this point
  """
  def data_tree_node_to_map(data_tree_node) do
    {:node, id, type, data, note, left, right, max} = data_tree_node
    %{
      id: id,
      type: type,
      data: data,
      note: note,
      left: left,
      right: right,
      max: max
    }
  end

  @doc """
  Data tree create chunks
  """
  def data_tree_to_chunks(data_tree) do
    data_tree
    |> Enum.filter(& elem(&1, 2)== :leaf)
    |> Enum.map(& elem(&1, 3))
  end

  def root_id(data_tree) do
    List.first(data_tree) |> elem(1)
  end

  def generate_data_path(tree, root_id, dest_id) do
    :ar_merkle.generate_path(root_id, dest_id, tree)
  end
end
