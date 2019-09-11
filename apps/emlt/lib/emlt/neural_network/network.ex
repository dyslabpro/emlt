defmodule Emlt.NN.Network do
  use GenServer

  alias Emlt.NN.{Neuron, Network}

  @doc """
  Запуск и линковка нашей очереди. Это вспомогательный метод.
  """
  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @doc """
  Функция обратного вызова для GenServer.init/1
  """
  def init(state) do
    init_data()

    {:ok, state}
  end

  defp init_data do
    init_data(0, 9, 1, 1, 3)
    init_data(1, 28, 1, 28, 2)
    init_data(1, 28, 1, 28, 1)
  end

  defp init_data(x_start, x_end, y_start, y_end, z) do
    for x <- x_start..x_end,
        y <- y_start..y_end,
        do: init_data_neuron(x, y, z)
  end

  defp init_data_neuron(x, y, z) do
    Neuron.insert({x, y, z, 0, 0})

    next_layer =
      case z do
        3 -> []
        2 -> get_last_layers()
        _ -> get_next_layers(x, y, z)
      end

    

    Enum.each(next_layer, fn nc ->
      Neuron.insert_nc({[{x, y, z}, nc.n_attr], nc.weight, nc.signal})
    end)
  end

  defp get_next_layers(x, y, z) do
    list =
      for i <- 1..28,
          j <- 1..28,
          into: [],
          do: %{
            n_attr: {i, j, z + 1},
            weight: Enum.random(-100..100) / 10,
            signal: 0
          }

    list |> Enum.filter(fn x -> is_map(x) end)
  end

  defp get_prev_layers(x, y, z) do
    list =
      for i <- 1..28,
          j <- 1..28,
          into: [],
          do: %{
            n_attr: {i, j, z - 1},
            weight: Enum.random(-100..100) / 10,
            signal: 0
          }

    list |> Enum.filter(fn x -> is_map(x) end)
  end

  defp get_last_layers() do
    list =
      for x <- 0..9,
          into: [],
          do: %{
            n_attr: {x, 1, 3},
            weight: Enum.random(-100..100) / 10,
            signal: 0
          }

    list
  end

  defp get_first_layers() do
    [
      %{
        n_attr: {0, 0, 0},
        weight: 1,
        signal: 0
      }
    ]
  end
end
