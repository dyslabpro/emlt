defmodule Emlt.Tools.Test do
  alias Emlt.Interfaces.Matrix

  def run() do
    "../../../../data/kaggle/digit_recognizer/test.csv"
    |> Path.expand(__DIR__)
    |> File.stream!()
    |> CSV.decode!()
    |> Enum.each(fn x ->
      dest = List.first(x)

      if dest != "pixel0" do
        matrix =
          x
          |> Enum.map(fn x -> String.to_integer(x) end)
          |> Enum.chunk_every(28)
          |> Matrex.new()

        Matrex.heatmap(matrix)
        Matrix.check(matrix)
      end
    end)
  end
end
