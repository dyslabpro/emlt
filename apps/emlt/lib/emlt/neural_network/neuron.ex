defmodule Emlt.NN.Neuron do
  def signal(n_attr, layer_prev, layer_conf) do
    neuron =
      n_attr
      |> get()

    signal_neuron =
      neuron.nc
      |> Matrex.new()
      |> Matrex.apply(layer_prev, fn w, s ->
        case s do
          0 -> 0
          _n -> w
        end
      end)
      |> Matrex.sum()

    neuron =
      neuron
      |> Map.merge(%{signal: signal_neuron})
      |> update()

    if sigmoid(signal_neuron) == 1 do
      neuron
      |> Map.merge(%{activated: 1})
      |> update
    end

    {:reply, :ok}
  end

  def delta(n_attr, layer_conf, layer_next, target) do
    neuron =
      n_attr
      |> get()

    if layer_conf.role == "out" do
      delta =
        if neuron.target == target do
          37 - neuron.signal
        else
          0 - neuron.signal
        end

      neuron
      |> Map.merge(%{delta: delta})
      |> update()
    else
      delta =
        layer_next
        |> Enum.reduce(0, fn n, acc ->
          w =
            neuron.nc
            |> Matrex.new()
            |> Matrex.at(neuron.x, neuron.y)

          w * n.delta + acc
        end)

      neuron
      |> Map.merge(%{delta: delta})
      |> update()
    end
  end

  def weight(w, rate, delta) do
    w + delta * rate
  end

  def change_weight(n_attr, layer_prev, layer_conf) do
    neuron =
      n_attr
      |> get()

    delta = neuron.delta * layer_conf.rate

    neuron_nc =
      neuron.nc
      |> Matrex.new()
      |> Matrex.apply(layer_prev, fn w, s ->
        case s do
          0 -> w
          _n -> w + delta
        end
      end)
      |> Matrex.to_list_of_lists()

    neuron
    |> Map.merge(%{nc: neuron_nc})
    |> update()
  end

  def change_weight1(n_attr, layer_prev, target, layer_conf) do
    # 37 
    neuron =
      n_attr
      |> get()

    if(layer_conf.role == "hidden") do
      neuron_nc =
        neuron.nc
        |> Matrex.new()
        |> Matrex.apply(layer_prev, fn w, s ->
          case s do
            0 -> w
            _n -> w + 0.01
          end
        end)
        |> Matrex.to_list_of_lists()

      neuron
      |> Map.merge(%{nc: neuron_nc})
      |> update()
    else
      delta =
        if neuron.target == target do
          if neuron.activated_value > 0 do
            0
          else
            0.01
          end
        else
          if neuron.activated_value > 0 do
            -0.01
          else
            0
          end
        end

      {x, y, z} = n_attr
      IO.puts("delta #{delta} for #{x}, #{y}, #{z} target- #{neuron.target}")

      neuron_nc =
        neuron.nc
        |> Matrex.new()
        |> Matrex.apply(layer_prev, fn w, s ->
          case s do
            0.0 ->
              w

            _n ->
              w + delta
          end
        end)
        |> Matrex.to_list_of_lists()

      neuron
      |> Map.merge(%{nc: neuron_nc})
      |> update()
    end
  end

  def to_start(n_attr) do
    neuron =
      n_attr
      |> get()
      |> Map.merge(%{signal: 0, delta: 0, activated: 0})
      |> update()
  end

  def update(neuron) do
    %{
      key: neuron.key,
      x: neuron.x,
      y: neuron.y,
      z: neuron.z,
      target: neuron.target,
      activated: neuron.activated,
      signal: neuron.signal,
      delta: neuron.delta,
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
  def insert(opts) when is_map(opts) do
    :ets.insert(
      :neurons,
      {{opts.x, opts.y, opts.z}, opts}
    )
  end

  def insert(opts) when is_tuple(opts) do
    {neuron, target} = opts

    neuron
    |> Map.merge(%{target: target})
    |> insert()
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

    if n.activated == 1 do
      true
    else
      nil
    end
  end

  def format(neuron, format) do
    target =
      if is_nil(neuron.target) do
        "NULL"
      else
        neuron.target
      end

    case format do
      :short ->
        %{
          key: neuron.key,
          activated: neuron.activated,
          signal: neuron.signal,
          delta: neuron.delta,
          target: target
        }

      :full ->
        neuron
    end
  end
end
