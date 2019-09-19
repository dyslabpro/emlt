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

  def handle_cast({:signal, n_attr}, state) do
    neuron =
      n_attr
      |> neuron_get()

    if(neuron.activated_value == 0) do
      neuron
      |> preload_inbound_connections()
      |> preload_outbound_connections()
      # |> update_inbound_connections(n_in, signal)
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
    |> neuron_insert()

    neuron
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
        %{
          key: oc.key,
          weight: oc.weight,
          signal: 1
        }
        |> nc_insert()
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
        |> nc_insert()
      end)
    else
      _neuron =
        neuron
        |> Map.merge(%{current_value: signal_neuron})
        |> neuron_update
    end
  end

  # ====================== End Learn section ========================
  def preload_inbound_connections(neuron) do
    list = nc_find({[:_, {neuron.x, neuron.y, neuron.z}], :_})
    inbound_connections = list |> Enum.map(fn inc -> elem(inc, 1) end)

    neuron |> Map.merge(%{inbound_connections: inbound_connections})
  end

  def preload_outbound_connections(neuron) do
    list = nc_find({[{neuron.x, neuron.y, neuron.z}, :_], :_})
    outbound_connections = list |> Enum.map(fn inc -> elem(inc, 1) end)

    neuron |> Map.merge(%{outbound_connections: outbound_connections})
  end

  # === Storage ===
  def neuron_insert(opts) do
    :ets.insert(
      :neurons,
      {{opts.x, opts.y, opts.z}, opts}
    )
  end

  def nc_insert(opts) do
    :ets.insert(:neuron_connections, {opts.key, opts})
  end

  def neuron_get(opts) do
    {_key, neuron} = :ets.lookup(:neurons, opts) |> hd
    neuron
  end

  def nc_get(opts) do
    :ets.lookup(:neuron_connections, opts)
  end

  def neurons_find(opts) do
    :ets.match_object(:neurons, opts)
  end

  def nc_find(opts) do
    :ets.match_object(:neuron_connections, opts)
  end
end
