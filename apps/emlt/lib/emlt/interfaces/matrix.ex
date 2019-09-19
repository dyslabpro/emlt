defmodule Emlt.Interfaces.Matrix do
  alias Emlt.NN.{Neuron, NeuronConnection}

  def learn(matrix, value) do
    IO.puts("learn nn for #{value}")
    {rows, cols} = Matrex.size(matrix)

    Enum.each(1..cols |> Enum.with_index(1), fn {_row, x} ->
      Enum.each(1..rows |> Enum.with_index(1), fn {_cell, y} ->
        if(matrix[x][y] > 0) do
          color_value = matrix[x][y]

          %{
            key: [{0, 0, 0}, {x, y, 1}],
            weight: 10,
            signal: color_value
          }
          |> NeuronConnection.update()
        end
      end)
    end)

    # :timer.sleep(3000)
    # IO.puts "Processing layer 1 "
    # Enum.each(1..cols |> Enum.with_index(1), fn {_row, x} ->
    #   Enum.each(1..rows |> Enum.with_index(1), fn {_cell, y} ->
    #     if(matrix[x][y] > 0) do
    #       Emlt.NN.Neuron.signal({x, y, 1})
    #     end
    #   end)
    # end)

    # :timer.sleep(3000)
    # IO.puts "Processing layer 2 "
    # for x <- 1..28,
    #     y <- 1..28,
    #     do: Emlt.NN.Neuron.signal({x, y, 2})

    # :timer.sleep(3000)
    # IO.puts "Processing layer 3 "
    # for x <- 1..9,
    #     do: Emlt.NN.Neuron.signal({x, 1, 3})

    IO.puts("Processing layer 1 ")
    tasks = prepare_neurons_for_layer(1)
    tasks_with_results = Task.yield_many(tasks, :infinity)
    # IO.inspect(tasks_with_results)
    IO.puts("Processing layer 2 ")
    tasks = prepare_neurons_for_layer(2)
    tasks_with_results = Task.yield_many(tasks, :infinity)
    # IO.inspect(tasks_with_results)
    IO.puts("Processing layer 3 ")
    tasks = prepare_neurons_for_last_layer(3)
    tasks_with_results = Task.yield_many(tasks, :infinity)
    # IO.inspect(tasks_with_results)
    Emlt.NN.Layer.get(3) |> IO.inspect()
    Emlt.NN.Layer.get_activated(3) |> IO.inspect()
    :ok
  end

  def prepare_neurons_for_layer(z) do
    for i <- 1..28,
        j <- 1..28,
        into: [],
        # {i, j, z}
        do:
          Task.async(Emlt.NN.NeuronRunner, :signal, [
            {i, j, z}
          ])
  end

  def prepare_neurons_for_last_layer(z) do
    for x <- 1..9,
        into: [],
        # {i, j, z}
        do:
          Task.async(Emlt.NN.NeuronRunner, :signal, [
            {x, 1, z}
          ])
  end
end
