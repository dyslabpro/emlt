defmodule Emlt.NN.Network do
  use GenServer

  alias Emlt.NN.{Neuron}

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    case Application.fetch_env!(:emlt, :mode) do
      :learn ->
        Application.fetch_env!(:emlt, :nn_layers)
        |> Enum.each(fn layer ->
          init_layer(layer)
        end)

      :test ->
        backup = Application.fetch_env!(:emlt, :backup)
        :dets.open_file(backup, type: :set)
        :ets.from_dets(:neurons, backup)
    end

    {:ok, state}
  end

  defp init_layer(layer) do
    {xm, ym} = layer.size

    list_of_neurons =
      for x <- 1..xm,
          y <- 1..ym,
          into: [],
          do: init_data_neuron({x, y, layer.z_index}, layer)

    list_of_neurons =
      case layer.role do
        "out" -> Enum.zip(list_of_neurons, layer.targets)
        _ -> list_of_neurons
      end

    list_of_neurons
    |> Enum.each(fn neuron ->
      neuron |> Neuron.insert()
    end)
  end

  defp init_data_neuron({x, y, z}, layer) do
    nc = Matrex.new(layer.size_nc, layer.size_nc, fn -> Enum.random(layer.nc_weights) end)

    %{
      key: {x, y, z},
      x: x,
      y: y,
      z: z,
      signal: 0,
      out: 0,
      delta: 0,
      nc: nc,
      target: "NULL"
    }
  end

  def to_start do
    tasks =
      :ets.match_object(:neurons, {{:_, :_, :_}, :_})
      |> Enum.map(fn neuron ->
        {key, _n} = neuron
        Task.async(Neuron, :to_start, [key])
      end)

    Task.yield_many(tasks, :infinity)
  end

  def config_data(key, z) do
    layers =
      Application.fetch_env!(:emlt, :nn_layers)
      |> Enum.filter(fn l ->
        l.z_index == z
      end)
      |> hd
      |> Map.fetch!(key)
  end
end
