defmodule Emlt.NN.Layer do
  alias Emlt.NN.{Layer, Neuron}

  def get_neyrons(layer) do
    :ets.match_object(:neurons, {{:_, :_, layer}, :_})
    |> Enum.map(fn x ->
      {_key, neuron} = x
      neuron
    end)
  end



  def get_matrix_from_layer(layer) do
    {w, _h} = Emlt.NN.Network.config_data(:size, layer)

    layer
    |> get_neyrons()
    |> Enum.sort(&(get_x(&1) <= get_x(&2)))
    |> Enum.sort(&(get_y(&1) <= get_y(&2)))
    |> Enum.map(fn n ->
      n.out
    end)
    |> Enum.chunk_every(w)
    |> Matrex.new()
  end

  def get_matrix_from_layer_with_signal(layer) do
    {w, _h} = Emlt.NN.Network.config_data(:size, layer)

    layer
    |> get_neyrons()
    |> Enum.sort(&(get_x(&1) <= get_x(&2)))
    |> Enum.sort(&(get_y(&1) <= get_y(&2)))
    |> Enum.map(fn n ->
      n.signal
    end)
    |> Enum.chunk_every(w)
    |> Matrex.new()
  end

  def get_x(n) do
    n.x
  end

  def get_y(n) do
    n.y
  end

  def get(n, key) do
    Map.fetch(n, key)
  end

  def inspect(z) do
    z
    |> Layer.get_neyrons()
    |> Enum.sort(&(get(&2, :out) <= get(&1, :out)))
    |> Enum.map(fn n ->
      Neuron.format(n, :line)
    end)
    |> IO.inspect()
  end

  # def call(task, opts) do
  #   {xm, ym} = layer_conf.size

  #   for i <- 1..xm,
  #       j <- 1..ym,
  #       into: [],
  #       do:
  #         opts = [{i, j, layer_conf.z_index} | opts]
  #         Task.async(Neuron, task, opts)
  # end
end
