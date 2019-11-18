defmodule Emlt.NN.Neuron do
  @moduledoc """
  The API for work with Neuron
  """
  
  alias Emlt.NN.{Neuron}

  def init({x, y, z}, layer_config) do
    nc =
      Matrex.new(layer_config.size_nc, layer_config.size_nc, fn ->
        Enum.random(layer_config.nc_weights)
      end)

    %{
      key: {x, y, z},
      table: layer_config.table,
      x: x,
      y: y,
      z: z,
      signal: 0,
      out: 0,
      delta: 0,
      nc: nc,
      target: "NULL"
    }
  end

  def signal(%{n_attr: n_attr, conf: conf, prev: prev} = _opts) do
    neuron =
      n_attr
      |> get(conf.table)

    signal_neuron =
      neuron.nc
      |> Matrex.apply(prev, fn w, s ->
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

  def delta(%{n_attr: n_attr, conf: conf, next: next, target: target} = _opts) do
    neuron =
      n_attr
      |> get(conf.table)

    if conf.role == "out" do
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
        next
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

  def change_weight(%{n_attr: n_attr, conf: conf, prev: prev} = _opts) do
    neuron =
      n_attr
      |> get(conf.table)

    delta = neuron.delta * conf.rate

    neuron_nc =
      neuron.nc
      |> Matrex.apply(prev, fn w, s ->
        # loss = loss(s)
        new_weight = w + delta * s

        # IO.puts "#{neuron.x} #{neuron.y} #{neuron.z} delta: #{neuron.delta}, s: #{s}, new_weight: #{new_weight}, old_w: #{w}"
        new_weight
      end)

    neuron
    |> Map.merge(%{nc: neuron_nc})
    |> update()
  end

  def to_start(n_attr, conf) do
    _neuron =
      n_attr
      |> get(conf.table)
      |> Map.merge(%{signal: 0, delta: 0, out: 0})
      |> update()
  end

  def update(neuron) do
    %{
      key: neuron.key,
      table: neuron.table,
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
      opts.table,
      {{opts.x, opts.y, opts.z}, opts}
    )
  end

  def insert(opts) when is_tuple(opts) do
    {neuron, target} = opts

    neuron
    |> Map.merge(%{target: target})
    |> insert()
  end

  def get(opts, table) do
    {_key, neuron} = :ets.lookup(table, opts) |> hd
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
        %{out: neuron.out, target: target}
    end
  end
end
