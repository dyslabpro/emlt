defmodule Emlt.NN.Network do
  use GenServer

  alias Emlt.NN.{Neuron, NeuronConnection}

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
    init_data(0, 9, 1, 1, 3)
    init_data(1, 28, 1, 28, 2)
    init_data(1, 28, 1, 28, 1)

    {:ok, state}
  end

  defp init_data(x_start, x_end, y_start, y_end, z) do
    for x <- x_start..x_end,
        y <- y_start..y_end,
        do: init_data_neuron(x, y, z)
  end

  defp init_data_neuron(x, y, z) do
    next_layer =
      case z do
        3 -> []
        2 -> Neuron.get_last_layers(x, y, z)
        _ -> Neuron.get_next_layers(x, y, z)
      end

    if z == 1 do
      %{
        key: [{0, 0, 0}, {x, y, z}],
        weight: 10,
        signal: 0
      }
      |> NeuronConnection.insert()
    end

    %{
      x: x,
      y: y,
      z: z,
      activated_value: 0,
      current_value: 0,
      inbound_connections: []
    }
    |> Neuron.insert()

    Enum.each(next_layer, fn nc ->
      NeuronConnection.insert(nc)
    end)
  end
end
