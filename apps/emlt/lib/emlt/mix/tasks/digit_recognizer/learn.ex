defmodule Mix.Tasks.Emlt.DigitRecognizer.Learn do
  use Mix.Task

  alias Emlt.Interfaces.Matrix

  @shortdoc "EML Digit Recognizer learn"

  def run(_) do
    Mix.Task.run("app.start")
    #:observer.start

    "../../../../../data/kaggle/digit_recognizer/train.csv"
    |> Path.expand(__DIR__)
    |> File.stream!()
    |> CSV.decode!()
    |> Enum.take(2)
    |> Enum.each(fn x ->
      dest = List.first(x)

      if dest != "label" do
        matrix =
          x
          |> List.delete_at(0)
          |> Enum.map(fn x -> String.to_integer(x) end)
          |> Enum.chunk_every(28)
          |> Matrex.new()

        #Matrex.heatmap(matrix)

        # spawn(Matrix, :learn, [matrix, dest])
        Matrix.learn(matrix, dest)
      
      end
    end)
    #Eml.NN.backup_layers(0, 9, 1, 1, 4)
    #Eml.NN.backup_layers(1, 7, 1, 7, 3)
    #Eml.NN.backup_layers(1, 14, 1, 14, 2)
    #Eml.NN.backup_layers(1, 28, 1, 28, 1)
    #Mix.Shell.IO.yes? "Exit?"
  end
end
