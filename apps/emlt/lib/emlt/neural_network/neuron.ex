defmodule Emlt.NN.Neuron do
  alias Emlt.NN.{Neuron}

  def signal(n_attr, layer_prev, _layer_conf) do
    neuron =
      n_attr
      |> get()

    signal_neuron =
      neuron.nc
      |> Matrex.apply(layer_prev, fn w, s ->
        w * s
      end)
      |> Matrex.sum()

    out = sigmoid(signal_neuron)

    neuron
    |> Map.merge(%{
      signal: signal_neuron,
      out: out
    })
    |> Neuron.update()

    {:reply, :ok}
  end

  def delta(n_attr, layer_conf, layer_next, target) do
    neuron =
      n_attr
      |> get()

    if layer_conf.role == "out" do
      delta =
        if neuron.target == target do
          1 - neuron.out
        else
          0 - neuron.out
        end

      neuron
      |> Map.merge(%{delta: delta})
      |> update()
    else
      delta =
        layer_next
        |> Enum.reduce(0, fn n, acc ->
          w =
            n.nc
            |> Matrex.at(neuron.x, neuron.y)

          w * n.delta + acc
        end)

      neuron
      |> Map.merge(%{delta: delta})
      |> update()
    end
  end

  def change_weight(n_attr, layer_prev, layer_conf) do
    neuron =
      n_attr
      |> get()

    delta = neuron.delta * layer_conf.rate

    neuron_nc =
      neuron.nc
      |> Matrex.apply(layer_prev, fn w, s ->
        #loss = loss(s)
        new_weight = w + (delta * s)
        #IO.puts "#{neuron.x} #{neuron.y} #{neuron.z} delta: #{neuron.delta}, s: #{s}, new_weight: #{new_weight}, old_w: #{w}"
        new_weight
        end)

    neuron
    |> Map.merge(%{nc: neuron_nc})
    |> update()
  end

  def to_start(n_attr) do
    neuron =
      n_attr
      |> get()
      |> Map.merge(%{signal: 0, delta: 0, out: 0})
      |> update()
  end

  def update(neuron) do
    %{
      key: neuron.key,
      x: neuron.x,
      y: neuron.y,
      z: neuron.z,
      target: neuron.target,
      out: neuron.out,
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

  def loss(out) do
    out * (1 - out)
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
          out: neuron.out,
          signal: neuron.signal,
          delta: neuron.delta,
          target: target
        }

      :full ->
        neuron

      :line ->
        %{out: neuron.out, target: target  } 
    end
  end
end
