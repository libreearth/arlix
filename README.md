# Arlix

**TODO: Add description**

## Remote node
For the runtime to work you need to init the node with a name with the elixir --sname parameter
> iex --sname=localname -S mix

After that to init the node
> Arlix.Runtime.ElixirStandalone.init()

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

This is just a proof of concept on how to connect to a running arweave node and use standar erlang rpc to create a transaction from elixir.

Steps (on iex):
1) load the key file wallet = :rpc.call(:"name@host", :ar_wallet, :load_keyfile, ["/file/path/arveawe/host/file/wallet.json"])
2) read the file {:ok, file} = :rpc.call(:"name@host", :file, :read_file, ["/file/path/arveawe/host/file"])
3) queue = :rpc.call(:"name@host", :app_queue, :start, [wallet])
4) create transaction record record = tx(tags: [{"Content-Type", "text/plain"}], data: file)
5) :rpc.call(:"namo@host", :app_queue, :add, [queue, record])

For this to work the nodes need to be connected. A name can be given to a running node with: net_kernel:start([ar01, shortnames]).

For this example we created a cookie file so both nodes are connected automatically on the same host.

The module containing the record definition needs to be loaded in elixir iex

To connect a node in iex: Node.connect :'name@host'

ToDo: use the transaction creation directly without the queue
