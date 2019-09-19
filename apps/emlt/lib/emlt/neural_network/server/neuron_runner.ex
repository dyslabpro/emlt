defmodule Emlt.NN.NeuronRunner do
  def signal(n_attr) do
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

    {:reply, :ok}
  end

  def neuron_update(neuron) do
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
      neuron =
        neuron
        |> Map.merge(%{activated_value: signal_neuron, current_value: 0})

      tasks1 =
        Enum.map(neuron.outbound_connections, fn oc ->
          Task.async(Emlt.NN.NeuronRunner, :nc_insert, [
            %{
              key: oc.key,
              weight: oc.weight,
              signal: 1
            }
          ])
        end)

      task = Task.async(Emlt.NN.NeuronRunner, :neuron_update, [neuron])

      tasks2 =
        Enum.map(neuron.inbound_connections, fn inc ->
          Task.async(Emlt.NN.NeuronRunner, :nc_insert, [
            %{
              key: inc.key,
              weight: inc.weight,
              signal: 0
            }
          ])
        end)

      tasks = [task | tasks1 ++ tasks2]
      tasks_with_results = Task.yield_many(tasks, :infinity)
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

  def ncs_update(opts) do
    :ets.update_element(:neurons, {:_, :_, 3}, {1, "asdasd"})
    :ets.lookup(:neurons, {{:_, :_, 3}, :_})
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
