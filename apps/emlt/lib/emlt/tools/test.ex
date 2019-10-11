defmodule Emlt.Tools.Test do
  alias Emlt.Interfaces.Matrix

  def run() do
    file =
      "apps/emlt/data/kaggle/digit_recognizer/s4.csv"
      |> Path.expand()
      |> Path.absname()
      |> File.open!([:write, :utf8])

    header =
      [["ImageId", "Label"]]
      |> CSV.encode()
      |> Enum.take(1)
      |> hd

    IO.write(file, header)

    "../../../data/kaggle/digit_recognizer/test.csv"
    |> Path.expand(__DIR__)
    |> File.stream!()
    |> CSV.decode!()
    # |> Enum.take(200)
    # |> Enum.drop(1)
    |> Stream.with_index()
    |> Enum.each(fn {x, i} ->
      dest = List.first(x)

      if dest != "pixel0" do
        IO.puts "#{i}"
        matrix =
          x
          |> Enum.map(fn x -> String.to_integer(x) end)
          |> Enum.chunk_every(28)
          |> Matrex.new()

        Matrex.heatmap(matrix)
        res = Matrix.check(matrix) |> IO.puts

        # out =
        #   [[i, res]]
        #   |> CSV.encode()
        #   |> Enum.take(1)
        #   |> hd

        # IO.write(file, out)
      end
    end)

    # table_data = [["ImageId", "Label"] | table_data]
    # table_data |> CSV.encode() |> Enum.each(&IO.write(file, &1))
  end
end
