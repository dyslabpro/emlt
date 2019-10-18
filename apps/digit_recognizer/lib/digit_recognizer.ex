defmodule DigitRecognizer do
  alias Emlt.NN.Network

  def init() do
    Application.fetch_env!(:digit_recognizer, :nn)
    |> Network.init()
  end

  def test() do
    conf = Application.fetch_env!(:digit_recognizer, :nn)

    file =
      "../data/s6.csv"
      |> Path.expand(__DIR__)
      |> Path.absname()
      |> File.open!([:write, :utf8])

    header =
      [["ImageId", "Label"]]
      |> CSV.encode()
      |> Enum.take(1)
      |> hd

    IO.write(file, header)

    "../data/test.csv"
    |> Path.expand(__DIR__)
    |> File.stream!()
    |> CSV.decode!()
    # |> Enum.take(200)
    |> Stream.with_index()
    |> Enum.each(fn {x, i} ->
      dest = List.first(x)

      if dest != "pixel0" do
        IO.puts("#{i}")

        matrix =
          x
          |> Enum.map(fn x -> String.to_integer(x) end)
          |> Enum.chunk_every(28)
          |> Matrex.new()          
          |> Matrex.normalize()

        res = Network.test(conf, matrix)

        out =
          [[i, res]]
          |> CSV.encode()
          |> Enum.take(1)
          |> hd

        IO.write(file, out)
      end
    end)
  end

  def backup do
    conf = Application.fetch_env!(:digit_recognizer, :nn)
    :dets.open_file(conf.backup, type: :set)
    :dets.from_ets(conf.backup, conf.table)
  end

  def learn(take, epochs) do
    # Mix.Task.run("app.start")
    # :observer.start
    for _x <- 1..epochs,
        do: run_epoch(take)
  end

  def run_epoch(take) do
    conf = Application.fetch_env!(:digit_recognizer, :nn)

    "../data/train.csv"
    |> Path.expand(__DIR__)
    |> File.stream!()
    |> CSV.decode!()
    #|> Enum.take(take)
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
          |> Matrex.normalize()

        #Matrex.heatmap(matrix)
        Network.learn(conf, matrix, dest)
        IO.write(".")
      end
    end)
  end
end
