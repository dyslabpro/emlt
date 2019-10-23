defmodule Titanik do
  alias Emlt.NN.Network

  def init() do
    Application.fetch_env!(:titanik, :nn)
    |> Network.init()
  end

  def test() do
    conf = Application.fetch_env!(:titanik, :nn)

    file =
      "../data/s1.csv"
      |> Path.expand(__DIR__)
      |> Path.absname()
      |> File.open!([:write, :utf8])

    header =
      [["PassengerId", "Survived"]]
      |> CSV.encode()
      |> Enum.take(1)
      |> hd

    IO.write(file, header)

    "../data/test.csv"
    |> Path.expand(__DIR__)
    |> File.stream!()
    |> CSV.decode!(headers: true)
    # |> Enum.take(take)
    |> Enum.each(fn x ->
      matrix = get_matrix_from_values(x)

      passenger_id =
        x
        |> Map.get("PassengerId")

      res = Network.test(conf, matrix)

      out =
        [[passenger_id, res]]
        |> CSV.encode()
        |> Enum.take(1)
        |> hd

      IO.write(file, out)
    end)
  end

  def backup do
    conf = Application.fetch_env!(:titanik, :nn)
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
    conf = Application.fetch_env!(:titanik, :nn)

    "../data/train.csv"
    |> Path.expand(__DIR__)
    |> File.stream!()
    |> CSV.decode!(headers: true)
    # |> Enum.take(take)
    |> Enum.each(fn x ->
      matrix = get_matrix_from_values(x)
      dest = get_dest_from_values(x)
      Network.learn(conf, matrix, dest)
      IO.write(".")
    end)
  end

  def get_matrix_from_values(x) do
    fare_max = 512.3292 - 10
    fare_min = 4.0125
    fare_range = fare_max - fare_min

    # %{
    #   "Age" => "22",
    #   "Cabin" => "",
    #   "Embarked" => "S",
    #   "Fare" => "7.25",
    #   "Name" => "Braund, Mr. Owen Harris",
    #   "Parch" => "0",
    #   "PassengerId" => "1",
    #   "Pclass" => "3",
    #   "Sex" => "male",
    #   "SibSp" => "1",
    #   "Survived" => "0",
    #   "Ticket" => "A/5 21171"
    # }

    matrix = Matrex.fill(10, 10, 0)
    # Age 1
    age =
      x
      |> Map.get("Age")

    if age != "" do
      age =
        age
        |> Integer.parse()
        |> Tuple.to_list()
        |> hd
        |> div(10)
        |> round()

      matrix = Matrex.set(matrix, 1, age + 1, 1)
    end

    # Cabin 2

    # Embarked 3
    emabarked = Map.get(x, "Embarked")

    matrix =
      case emabarked do
        "C" -> Matrex.set(matrix, 3, 1, 1)
        "S" -> Matrex.set(matrix, 3, 2, 1)
        "Q" -> Matrex.set(matrix, 3, 3, 1)
        _ -> matrix
      end

    # Fare 4
    fare =
      x
      |> Map.get("Fare")

    if fare != "" do
      fare =
        fare
        |> Integer.parse()
        |> Tuple.to_list()
        |> hd

      fare = round((fare - fare_min) / fare_range * 10) + 1

      fare =
        if fare > 10 do
          10
        else
          fare
        end

      matrix = Matrex.set(matrix, 4, fare, 1)
    end

    # Name 
    # Parch 5
    parch =
      x
      |> Map.get("Parch")
      |> String.to_integer()

    matrix = Matrex.set(matrix, 5, parch + 1, 1)

    # PassengerId  
    # Pclass 6 
    pclass =
      x
      |> Map.get("Pclass")
      |> String.to_integer()

    matrix = Matrex.set(matrix, 6, pclass, 1)
    # Sex  7
    sex = Map.get(x, "Sex")

    matrix =
      case sex do
        "male" -> Matrex.set(matrix, 7, 1, 1)
        "female" -> Matrex.set(matrix, 7, 2, 1)
        _ -> matrix
      end

    # SibSp 8
    sibsp =
      x
      |> Map.get("SibSp")
      |> String.to_integer()

    matrix = Matrex.set(matrix, 8, sibsp + 1, 1)
    # Survived
    # Ticket 9 

    matrix
  end

  def get_dest_from_values(x) do
    x
    |> Map.get("Survived")
    |> String.to_integer()
  end
end
