defmodule Arlix.TransactionSaver do
  use GenServer

  alias Arlix.HttpApi

  @interval 1000*60*5

  def start_link([]) do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    Process.send_after(self(), :tick, @interval)
    {:ok, %{queue: :queue.new , saving_tx: nil}}
  end

  def handle_info(:tick, %{queue: {[],[]}, saving_tx: nil} = state) do
    Process.send_after(self(), :tick, @interval)
    {:noreply, state}
  end

  def handle_info(:tick, %{queue: q, saving_tx: nil}) do
    {{:value, tx}, sq} = :queue.out(q)
    case HttpApi.post_transaction(tx) do
      {:ok, _tx_map} ->
        Process.send_after(self(), :tick, @interval)
        {:noreply, %{queue: sq, saving_tx: tx}}
      _error ->
        Process.send_after(self(), :tick, @interval)
        {:noreply, %{queue: q, saving_tx: nil}}
    end
  end

  def handle_info(:tick, %{queue: q, saving_tx: %{"id" => sid}} = status) do
    case HttpApi.tx_status(sid) do
      :pending ->
        Process.send_after(self(), :tick, @interval)
        {:noreply, status}
      :not_found ->
        handle_info(:tick, %{queue: q, saving_tx: nil})
      :ok ->
        handle_info(:tick, %{queue: q, saving_tx: nil})
    end
  end

  def handle_cast({:queue_transaction, transaction}, state) do
    {:noreply, Map.put(state, :queue, :queue.in(transaction, state.queue))}
  end

  def queue_transaction(pid, transaction) do
    GenServer.cast(pid, {:queue_transaction, transaction})
  end
end
