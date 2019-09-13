defmodule Emlt.NN.StorageWorker do
  @moduledoc false
 
  use GenServer
  # API
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, [])
  end

  # APi

  # Callbacks
  def init(state) do
    {:ok, state}
  end

  def handle_cast({:insert, opts}, state) do
    :ets.insert(
      :neurons,
      {{opts.x, opts.y, opts.z}, opts}
    )
    {:noreply, state}
  end

  def handle_cast({:insert_nc, opts}, state) do
    :ets.insert(:neuron_connections, {opts.key, opts})
    {:noreply, state}
  end

  def handle_call({:lookup, opts}, _from, state) do
    n = :ets.lookup(:neurons, opts)
    {:reply, n, state}
  end

  def handle_call({:lookup_nc, opts}, _from, state) do
    n = :ets.lookup(:neuron_connections, opts)
    {:reply, n, state}
  end

end
