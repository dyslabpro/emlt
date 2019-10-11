defmodule Emlt.Interfaces.Matrix do
  alias Emlt.NN.{Neuron, Layer}

  def learn(layer_in, target) do
    layer_in =
      layer_in
      |> Matrex.apply(fn val ->
        case val do
          0.0 -> 0
          _ -> 1
        end
      end)

    # IO.inspect(layer_in)
    #IO.puts("learn NN for #{target}")
    IO.write(".")

    layers_conf = Application.fetch_env!(:emlt, :nn_layers)
    # ============================== Signal ==============================
    layers_conf
    |> Enum.each(fn layer_conf ->
      layer_prev =
        case layer_conf.z_index do
          2 -> layer_in
          _ -> Layer.get_matrix_from_layer(layer_conf.z_index - 1)
        end

      tasks = call_to_layer(layer_conf, layer_prev)
      Task.yield_many(tasks, :infinity)
    end)

    # ============================== Delta ==============================
    layers_conf
    |> Enum.reverse()
    |> Enum.each(fn layer_conf ->
      layer_next =
        case layer_conf.z_index do
          3 -> []
          _ -> Layer.get_neyrons(layer_conf.z_index + 1)
        end

      tasks = call_to_layer_delta(layer_conf, layer_next, target)
      Task.yield_many(tasks, :infinity)
    end)

    # ============================== weight ==============================
    layers_conf
    |> Enum.reverse()
    |> Enum.each(fn layer_conf ->
      layer_prev =
        case layer_conf.z_index do
          2 -> layer_in
          _ -> Layer.get_matrix_from_layer(layer_conf.z_index - 1)
        end

      tasks = call_to_layer_weight(layer_conf, layer_prev)
      Task.yield_many(tasks, :infinity)
    end)

    #Layer.inspect(3)
    Emlt.NN.Network.to_start()
    :ok
  end

  def call_to_layer(layer_conf, layer_prev) do
    {xm, ym} = layer_conf.size

    for i <- 1..xm,
        j <- 1..ym,
        into: [],
        do:
          Task.async(Neuron, :signal, [
            {i, j, layer_conf.z_index},
            layer_prev,
            layer_conf
          ])
  end

  def call_to_layer_delta(layer_conf, layer_next, target) do
    {xm, ym} = layer_conf.size

    for i <- 1..xm,
        j <- 1..ym,
        into: [],
        do:
          Task.async(Neuron, :delta, [
            {i, j, layer_conf.z_index},
            layer_conf,
            layer_next,
            target
          ])
  end

  def call_to_layer_weight(layer_conf, layer_prev) do
    {xm, ym} = layer_conf.size

    for i <- 1..xm,
        j <- 1..ym,
        into: [],
        do:
          Task.async(Neuron, :change_weight, [
            {i, j, layer_conf.z_index},
            layer_prev,
            layer_conf
          ])
  end

  def get_delta(x, value) do
    if x == value do
      0.25
    else
      -0.25
    end
  end

  def check(layer_in) do
    layer_in =
      layer_in
      |> Matrex.apply(fn val ->
        case val do
          0.0 -> 0
          _ -> 1
        end
      end)

    layers_conf = Application.fetch_env!(:emlt, :nn_layers)
    # ============================== Signal ==============================
    layers_conf
    |> Enum.each(fn layer_conf ->
      layer_prev =
        case layer_conf.z_index do
          2 -> layer_in
          _ -> Layer.get_matrix_from_layer(layer_conf.z_index - 1)
        end

      tasks = call_to_layer(layer_conf, layer_prev)
      Task.yield_many(tasks, :infinity)
    end)

    #Layer.inspect(3)
    target = Layer.get_res(3)
    Emlt.NN.Network.to_start()
    target
  end
end
