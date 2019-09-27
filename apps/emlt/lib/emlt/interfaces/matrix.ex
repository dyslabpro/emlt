defmodule Emlt.Interfaces.Matrix do
  alias Emlt.NN.{Neuron, Layer}

  def learn(layer_in, target) do
    IO.puts("learn NN for #{target}")

    layers_conf = Application.fetch_env!(:emlt, :nn_layers)

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

 

    Layer.inspect(3)
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
end
