defmodule Emlt.NN.Network do
  use GenServer

  alias Emlt.NN.{Neuron}

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

    {:ok, state}
  end

  defp init_data(x_start, x_end, y_start, y_end, z) do
    for x <- x_start..x_end,
        y <- y_start..y_end,
        do: init_data_neuron(x, y, z)
  end

  defp init_data_neuron(x, y, z) do
    nc = Matrex.new(28, 28, fn -> Enum.random(-14..14) end) |> Matrex.to_list_of_lists()

    %{
      key: {x, y, z},
      x: x,
      y: y,
      z: z,
      activated_value: 0,
      current_value: 0,
      nc: nc
    }
    |> Neuron.insert()
  end

  def to_start do
    tasks =
      :ets.match_object(:neurons, {{:_, :_, :_}, :_})
      |> Enum.filter(fn n ->
        Neuron.activated(n)
      end)
      |> Enum.map(fn neuron ->
        {key, _n} = neuron
        Task.async(Neuron, :to_start, [key])
      end)

    Task.yield_many(tasks, :infinity)
  end
end
