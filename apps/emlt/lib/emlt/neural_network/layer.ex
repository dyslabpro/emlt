defmodule Emlt.NN.Layer do
  alias Emlt.NN.{Layer, Neuron}

  def get_neyrons(layer) do
    :ets.match_object(:neurons, {{:_, :_, layer}, :_})
    |> Enum.map(fn x ->
      {_key, neuron} = x
      neuron
    end)
  end

  def get_activated_neyrons(layer) do
    layer
    |> Layer.get_neyrons()
    |> Enum.filter(fn n ->
      n.activated_value > 0
    end)
  end

  def get_correct_activated_neyrons(layer, value) do
    layer
    |> Layer.get_activated_neyrons()
    |> Enum.filter(fn n ->
      n.x == value
    end)
  end

  def get_not_correct_activated_neyrons(layer, value) do
    layer
    |> Layer.get_activated_neyrons()
    |> Enum.filter(fn n ->
      n.x != value
    end)
  end

  def insert(opts) do
    :ets.insert(
      :layers,
      {opts.layer, opts}
    )
  end

  def get(opts) do
    {_key, layer} = :ets.lookup(:layers, opts) |> hd
    layer
  end

  def get_matrix_from_layer(layer) do
    layer
    |> get_neyrons()
    |> Enum.sort(&(get_x(&1) <= get_x(&2)))
    |> Enum.sort(&(get_y(&1) <= get_y(&2)))
    |> Enum.map(fn n ->
      case n.activated_value do
        0 -> 0
        _ -> 1
      end
    end)
    |> Enum.chunk_every(28)
    |> Matrex.new()
  end

  def get_x(n) do
    n.x
  end

  def get_y(n) do
    n.y
  end

  def inspect(z) do
    z
    |> Layer.get_activated_neyrons()
    |> Enum.map(fn n ->
      Neuron.format(n, :short)
    end)
    |> IO.inspect
  end
end
