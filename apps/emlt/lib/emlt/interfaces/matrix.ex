defmodule Emlt.Interfaces.Matrix do
  alias Emlt.NN.{Neuron, Layer}

  def learn(layer_in, value) do
    IO.puts("learn nn for #{value}")

    IO.puts("Processing layer 2 ")
    tasks = call_to_layer(2, layer_in)
    Task.yield_many(tasks, :infinity)

    layer_hidden = Layer.get_matrix_from_layer(2)

    IO.puts("Processing layer 3 ")
    tasks = call_to_layer_last_layer(3, layer_hidden)
    Task.yield_many(tasks, :infinity)
    Layer.inspect(3)

    IO.puts("Change weights for layer 3 ")
    tasks = change_weight_in_last_layer(3, layer_hidden, value)
    Task.yield_many(tasks, :infinity)

    Layer.inspect(3)

    Emlt.NN.Network.to_start()
    :ok
  end

  def call_to_layer(z, layer) do
    for i <- 1..28,
        j <- 1..28,
        into: [],
        # {i, j, z}
        do:
          Task.async(Neuron, :signal, [
            {i, j, z},
            layer
          ])
  end

  def call_to_layer_last_layer(z, layer) do
    for x <- 1..9,
        into: [],
        # {i, j, z}
        do:
          Task.async(Neuron, :signal, [
            {x, 1, z},
            layer
          ])
  end

  def change_weight_in_last_layer(z, layer, value) do
    tasks1 =
      Layer.get_not_correct_activated_neyrons(z, value)
      |> Enum.map(fn neuron ->
        Task.async(Neuron, :change_weight, [neuron.key, layer, -0.25])
      end)

    tasks2 =
      case Layer.get_correct_activated_neyrons(z, value) do
        [] ->
          [Task.async(Neuron, :change_weight, [{value, 1, 3}, layer, 0.25])]

        _ ->
          []
      end

    tasks1 ++ tasks2
  end

  def get_delta(x, value) do
    if x == value do
      0.25
    else
      -0.25
    end
  end
end
