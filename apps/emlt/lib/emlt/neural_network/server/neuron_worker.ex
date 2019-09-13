defmodule Emlt.NN.NeuronWorker do
  @moduledoc false
  alias Emlt.NN.Neuron

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

  
  def handle_cast({:signal, %{n_in: n_in, n_out: n_out, msg: msg}}, state) do
    neuron =
      n_out
      |> Neuron.get()
      |> Neuron.preload_inbound_connections()

    IO.inspect(neuron)

    {:noreply, state}
  end

  # ====================== End Learn section ========================
end
