defmodule Emlt.NN.Neuron do
  def signal(n_attr, layer) do
    neuron =
      n_attr
      |> get()

    signal_neuron =
      neuron.nc
      |> Matrex.new()
      |> Matrex.apply(layer, fn w, s ->
        case s do
          0 -> 0
          _n -> w
        end
      end)
      |> Matrex.sum()

    if sigmoid(signal_neuron) == 1 do
      neuron
      |> Map.merge(%{activated_value: signal_neuron, current_value: 0})
      |> update()
    else
      neuron
      |> Map.merge(%{current_value: signal_neuron})
      |> update
    end

    {:reply, :ok}
  end

  def change_weight(n_attr, layer, delta) do
    neuron =
      n_attr
      |> get()

    neuron_nc =
      neuron.nc
      |> Matrex.new()
      |> Matrex.apply(layer, fn w, s ->
        case s do
          0.0 -> w
          _n -> w + delta
        end
      end)
      |> Matrex.to_list_of_lists()

    neuron
    |> Map.merge(%{nc: neuron_nc})
    |> update()
  end

  def to_start(n_attr) do
    neuron =
      n_attr
      |> get()
      |> Map.merge(%{activated_value: 0, current_value: 0})
      |> update()
  end

  def update(neuron) do
    %{
      key: neuron.key,
      x: neuron.x,
      y: neuron.y,
      z: neuron.z,
      activated_value: neuron.activated_value,
      current_value: neuron.current_value,
      nc: neuron.nc
    }
    |> insert()

    neuron
  end

  def sigmoid(x) do
    cond do
      x > 100 -> 1
      x < -100 -> 0
      true -> 1 / (1 + :math.exp(-x))
    end
  end

  # === Storage ===
  def insert(opts) do
    :ets.insert(
      :neurons,
      {{opts.x, opts.y, opts.z}, opts}
    )
  end

  def get(opts) do
    {_key, neuron} = :ets.lookup(:neurons, opts) |> hd
    neuron
  end

  def find(opts) do
    :ets.match_object(:neurons, opts)
  end

  def get_activated_value(neuron) do
    {_key, n} = neuron
    n.activated_value
  end

  def activated(neuron) do
    {_key, n} = neuron

    if n.activated_value > 0 || n.current_value > 0 do
      true
    else
      nil
    end
  end

  def format(neuron, format) do
    case format do
      :short ->
        %{
          key: neuron.key,
          activated_value: neuron.activated_value,
          current_value: neuron.current_value
        }

      :full ->
        neuron
    end
  end
end
