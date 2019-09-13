defmodule Emlt.NN.NeuronConnection do
  alias Emlt.NN.{Neuron, Network, NeuronConnection, Storage}
  @pool_name :neuron_worker_pool

  def insert(opts) do
    Storage.insert_nc opts
  end

  def get(opts) do
    Storage.get_nc opts
  end

  def update(opts) do
    Storage.update_nc opts
  end
end
