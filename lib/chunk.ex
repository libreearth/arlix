defmodule Arlix.Chunk do
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

  Returns a list of this map:
  %{
  "data_root" => "<Base64URL encoded data merkle root>",
  "data_size" => "a number, the size of transaction in bytes",
  "data_path" => "<Base64URL encoded inclusion proof>",
  "chunk" => "<Base64URL encoded data chunk>",
  "offset" => "<a number from [start_offset, start_offset + chunk size), relative to other chunks>"
  }
  """
  def data_tree_to_chunks(data_tree, merkle_root_b64, tx_size) do
    data_tree
    |> Enum.filter(& elem(&1, 2)== :leaf)
    |> Enum.map(&data_tree_node_to_map/1)
    |> Enum.reduce({[],0}, fn node, {chunks, offset} ->
        chunk = node_to_chunk(node, data_tree, merkle_root_b64, tx_size, offset)
        {chunks++[chunk], offset + byte_size(node.data)}
      end)
    |> elem(0)
  end

  @doc """
  Data tree node to a chunk
  %{
    "data_root" => "<Base64URL encoded data merkle root>",
    "data_size" => "a number, the size of transaction in bytes",
    "data_path" => "<Base64URL encoded inclusion proof>",
    "chunk" => "<Base64URL encoded data chunk>",
    "offset" => "<a number from [start_offset, start_offset + chunk size), relative to other chunks>"
  }
  """
  def node_to_chunk(node, tree, merkle_root_b64, tx_size, offset) do
    %{
      "data_root" => merkle_root_b64,
      "data_size" => tx_size,
      "data_path" => generate_data_path(tree, root_id(tree), node.id) |> Base.url_encode64(padding: false),
      "chunk" => Base.url_encode64(node.data, padding: false),
      "offset" => offset
    }
  end

  def root_id(data_tree) do
    List.first(data_tree) |> elem(1)
  end

  def generate_data_path(tree, root_id, dest_id) do
    :ar_merkle.generate_path(root_id, dest_id, tree)
  end
end
