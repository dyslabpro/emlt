defmodule Emlt.Interfaces.Matrix do
  def learn(matrix, value) do
    IO.puts("learn nn for #{value}")
    {rows, cols} = Matrex.size(matrix)

    Enum.each(1..cols |> Enum.with_index(1), fn {_row, x} ->
      Enum.each(1..rows |> Enum.with_index(1), fn {_cell, y} ->
        if(matrix[x][y] > 0) do
          color_value = matrix[x][y]

          %{
            n_out: {x, y, 1},
            n_in: {0, 0, 0},
            msg: color_value
          }
          |> Emlt.NN.Neuron.signal()
        end
      end)
    end)

    # Process.sleep(200)

    # _out_correct =
    #   Eml.NN.Layer.get(3)
    #   |> Enum.filter(fn x -> x.attr.x == value |> String.to_integer() end)
    #   |> Enum.each(fn n ->
    #     Eml.NN.Neuron.change_weight({n.attr.x, n.attr.y, 3}, "up")
    #     Process.sleep(200)
    #   end)

    # _out_incorrect =
    #   Eml.NN.Layer.get(3)
    #   |> Enum.filter(fn x -> x.attr.x != value |> String.to_integer() end)
    #   |> Enum.each(fn n ->
    #     Eml.NN.Neuron.change_weight({n.attr.x, n.attr.y, 3}, "down")
    #     Process.sleep(200)
    #   end)

    # Mix.Shell.IO.yes?("Clear?")

    # Enum.each(1..3, fn z ->
    #   Eml.NN.Layer.get(z)
    #   |> Enum.each(fn n ->
    #     Eml.NN.Neuron.clear_signal({n.attr.x, n.attr.y, z})
    #     Process.sleep(200)
    #   end)
    # end)
  end

  # def check(matrix) do
  #   matrix |> Matrex.heatmap()
  #   {rows, cols} = Matrex.size(matrix)

  #   Enum.each(1..cols |> Enum.with_index(1), fn {_row, x} ->
  #     Enum.each(1..rows |> Enum.with_index(1), fn {_cell, y} ->
  #       if(matrix[x][y] > 0) do
  #         color_value = matrix[x][y] |> Float.to_string()
  #         Eml.NN.Neuron.signal({x, y, 1}, {1, 1}, color_value)
  #       end
  #     end)
  #   end)

  #   Eml.NN.Layer.get(4) |> IO.inspect()
  #   Mix.Shell.IO.yes?("Continue?")
  #   Eml.NN.Layer.flush(4)
  # end
end
