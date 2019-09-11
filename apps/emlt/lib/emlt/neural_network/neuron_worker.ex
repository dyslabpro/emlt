defmodule Emlt.NN.NeuronWorker do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, [])
  end

  def init(neuron) do
    {:ok, neuron}
  end

  def handle_cast({:insert, n_attr}, neuron) do
    {x, y, z, activated_value, current_value} = n_attr
    :ets.insert(:neurons, {{x, y, z}, x, y, z, activated_value, current_value})
    {:noreply, neuron}
  end

  def handle_cast({:insert_nc, nc_attr}, neuron) do
    {key, weight, signal} = nc_attr
    [n_in, n_out] = key
    :ets.insert(:neuron_connections, {key, n_in, n_out, weight, signal})
    {:noreply, neuron}
  end

  def handle_call({:lookup, n_attr}, _from, neuron) do
    n = :ets.lookup(:neurons, n_attr)
    {:reply, n, neuron}
  end

  def handle_call({:lookup_nc, nc_attr}, _from, neuron) do
    n = :ets.lookup(:neuron_connections, nc_attr)
    {:reply, n, neuron}
  end
end
