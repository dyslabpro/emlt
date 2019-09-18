defmodule Emlt.NN.NeuronWorker do
  @moduledoc false
  alias Emlt.NN.{Neuron, NeuronConnection}

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

  def handle_cast({:signal, %{n_in: n_in, n_out: n_out, signal: signal}}, state) do
    neuron =
      n_out
      |> Neuron.get()

    if(neuron.activated_value == 0) do
      neuron
      |> Neuron.preload_inbound_connections()
      |> Neuron.preload_outbound_connections()
      |> update_inbound_connections(n_in, signal)
      |> check_activate()
    end

    {:noreply, state}
  end

  defp neuron_update(neuron) do
    %{
      x: neuron.x,
      y: neuron.y,
      z: neuron.z,
      activated_value: neuron.activated_value,
      current_value: neuron.current_value,
      inbound_connections: []
    }
    |> Neuron.update()

    neuron
  end

  defp update_inbound_connections(neuron, n_in, signal) do
    inbound_connections =
      neuron.inbound_connections
      |> Enum.map_every(1, fn inc ->
        [inc_in, _inc_out] = inc.key

        if inc_in == n_in do
          %{
            key: inc.key,
            weight: inc.weight,
            signal: signal
          }
          |> NeuronConnection.update()

          inc |> Map.merge(%{signal: signal})
        else
          inc
        end
      end)

    neuron |> Map.merge(%{inbound_connections: inbound_connections})
  end

  defp sigmoid(x) do
    1 / (1 + Math.exp(-x))
  end

  defp get_signal_neuron(neuron) do
    neuron.inbound_connections
    |> Enum.reduce(0, fn inc, acc -> inc.signal * inc.weight + acc end)
  end

  defp check_activate(neuron) do
    signal_neuron = get_signal_neuron(neuron)

    if sigmoid(signal_neuron) == 1 do
      Enum.each(neuron.outbound_connections, fn oc ->
        [n_in, n_out] = oc.key

        %{
          n_out: n_out,
          n_in: n_in,
          signal: 1
        }
        |> Emlt.NN.Neuron.signal()
      end)

      _neuron =
        neuron
        |> Map.merge(%{activated_value: signal_neuron, current_value: 0})
        |> neuron_update

      Enum.each(neuron.inbound_connections, fn inc ->
        %{
          key: inc.key,
          weight: inc.weight,
          signal: 0
        }
        |> NeuronConnection.update()
      end)
    else
      _neuron =
        neuron
        |> Map.merge(%{current_value: signal_neuron})
        |> neuron_update
    end
  end

  # ====================== End Learn section ========================
end
