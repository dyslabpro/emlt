defmodule Emlt.Tools.Learn do
  alias Emlt.Interfaces.Matrix

  def run() do
    # Mix.Task.run("app.start")
    # :observer.start

    "../../../data/kaggle/digit_recognizer/train.csv"
    |> Path.expand(__DIR__)
    |> File.stream!()
    |> CSV.decode!()
    |> Enum.take(20)
    |> Enum.each(fn x ->
      dest = List.first(x)

      if dest != "label" do
        dest = dest |> String.to_integer()

        matrix =
          x
          |> List.delete_at(0)
          |> Enum.map(fn x -> String.to_integer(x) end)
          |> Enum.chunk_every(28)
          |> Matrex.new()

        # Matrix.learn(matrix, dest)
        {uSecs, :ok} = :timer.tc(Matrix, :learn, [matrix, dest])
        IO.inspect(uSecs)
      end
    end)
  end
end
