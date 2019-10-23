defmodule Emlt.NN.Layer do
  @moduledoc """
  The API for work with layer of Neural network.
  """
  
  alias Emlt.NN.{Layer, Neuron}

  def init(config) do
    {xm, ym} = config.size

    list_of_neurons =
      for x <- 1..xm,
          y <- 1..ym,
          into: [],
          do: Neuron.init({x, y, config.z_index}, config)

    list_of_neurons =
      case config.role do
        "out" -> Enum.zip(list_of_neurons, config.targets)
        _ -> list_of_neurons
      end

    list_of_neurons
    |> Enum.each(fn neuron ->
      neuron |> Neuron.insert()
    end)
  end

  def get_neyrons(layer, config) do
    :ets.match_object(config.table, {{:_, :_, layer}, :_})
    |> Enum.map(fn x ->
      {_key, neuron} = x
      neuron
    end)
  end

  def get_matrix_from_layer(layer, config) do
     {w, _} = config.size

    layer
    |> get_neyrons(config)
    |> Enum.sort(&(get_x(&1) <= get_x(&2)))
    |> Enum.sort(&(get_y(&1) <= get_y(&2)))
    |> Enum.map(fn n ->
      n.out
    end)
    |> Enum.chunk_every(w)
    |> Matrex.new()
  end

  def get_matrix_from_layer_with_signal(layer, config) do
    {w, _h} = Emlt.NN.Network.config_data(:size, layer)

    layer
    |> get_neyrons(config)
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

  def inspect(z, config) do
    z
    |> Layer.get_neyrons(config)
    |> Enum.sort(&(get(&2, :out) <= get(&1, :out)))
    |> Enum.map(fn n ->
      Neuron.format(n, :line)
    end)
    |> IO.inspect()
  end

  def get_res(z, config) do
    z
    |> Layer.get_neyrons(config)
    |> Enum.sort(&(get(&2, :out) <= get(&1, :out)))
    |> hd
    |> Map.fetch!(:target)
  end

  def prepare_tasks(%{task: task, conf: conf} = opts) do
    {xm, ym} = conf.size

    task_opts =
      case task do
        :signal -> %{conf: conf, prev: opts.prev}
        :delta -> %{conf: conf, next: opts.next, target: opts.target}
        :change_weight -> %{conf: conf, prev: opts.prev}
      end

    for i <- 1..xm,
        j <- 1..ym,
        into: [],
        do: Task.async(Neuron, task, [Map.merge(task_opts, %{n_attr: {i, j, conf.z_index}})])
  end
end
