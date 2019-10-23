defmodule Emlt.NN.Network do
  @moduledoc """
  Provide the API for work with Neural network
  """
  alias Emlt.NN.{Neuron, Layer, Network, Config}

  @doc """
  Init new Neural network by the config.
  If we will use mode test, nn will restored from backup file, else will created new.


  ## Examples

   
      %{
        table: :digit_recognizer_neurons,     # table name in ets
        mode: :learn,                         # neural network mode (test or learn)
        backup: 'neurons-6.dets',             # dets backup file for neural network
        layers: [
          %{
            size: {17, 17},                   # size of matrix for this layer
            size_nc: 28,                      # size of neuron connections with previos layers
            nc_weights: -5..5,                #range for weight for neuron connection in init
            z_index: 2,                       # index of layer
            targets: nil,                     # targets value for layer with role: out
            role: "hidden",                   # role of layer(hidden|out)
            rate: 0.1
          },
          %{
            size: {10, 10},
            size_nc: 17,
            nc_weights: -5..5,
            z_index: 3,
            targets: nil,
            role: "hidden",
            rate: 0.1
          },
          %{
            size: {1, 10},
            size_nc: 10,
            nc_weights: -5..5,
            z_index: 4,
            targets: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
            role: "out",
            rate: 0.1
          }
        ]
      } |> Emlt.NN.Network.init    

  """
  @spec init(Config.t()) :: atom()
  def init(config) do
    case config.mode do
      :learn ->
        config.layers
        |> Enum.each(fn layer_config ->
          layer_config
          |> Map.merge(%{
            table: config.table
          })
          |> Layer.init()
        end)

      :test ->
        :dets.open_file(config.backup, type: :set)
        :ets.from_dets(config.table, config.backup)
    end

    :ok
  end

  @doc """
    Send signal as matrix to Neural network for learn
  """
  @spec learn(Config.t(), Matrex.t(), any) :: :ok
  def learn(config, signal, target) do
    Network.signal(config, signal)
    # Layer.inspect(4, config)

    Network.delta(config, signal, target)
    Network.weight(config, signal, target)
    Network.to_start(config)

    :ok
  end

  @doc """
    Send signal as matrix to Neural network for test
  """
  @spec test(Config.t(), Matrex.t()) :: any
  def test(config, signal) do
    Network.signal(config, signal)
    target = Layer.get_res(3, config)
    Network.to_start(config)
    target
  end

  @doc false
  def get_conf(config, layer) do
    config.layers
    |> Enum.filter(fn x -> x.z_index == layer end)
    |> hd
    |> Map.merge(%{
      table: config.table
    })
  end

  defp signal(config, signal) do
    config.layers
    |> Enum.each(fn conf ->
      conf = Map.merge(conf, %{table: config.table})

      prev =
        case conf.z_index do
          2 -> signal
          _ -> Layer.get_matrix_from_layer(conf.z_index - 1, get_conf(config, conf.z_index - 1))
        end

      %{
        task: :signal,
        conf: conf,
        prev: prev
      }
      |> Layer.prepare_tasks()
      |> Task.yield_many(:infinity)
    end)
  end

  defp delta(config, _signal, target) do
    config.layers
    |> Enum.reverse()
    |> Enum.each(fn conf ->
      conf = Map.merge(conf, %{table: config.table})

      next =
        case conf.z_index do
          3 -> []
          _ -> Layer.get_neyrons(conf.z_index + 1, conf)
        end

      %{
        task: :delta,
        conf: conf,
        next: next,
        target: target
      }
      |> Layer.prepare_tasks()
      |> Task.yield_many(:infinity)
    end)
  end

  defp weight(config, signal, _target) do
    config.layers
    |> Enum.reverse()
    |> Enum.each(fn conf ->
      conf = Map.merge(conf, %{table: config.table})

      prev =
        case conf.z_index do
          2 -> signal
          _ -> Layer.get_matrix_from_layer(conf.z_index - 1, get_conf(config, conf.z_index - 1))
        end

      %{
        task: :change_weight,
        conf: conf,
        prev: prev
      }
      |> Layer.prepare_tasks()
      |> Task.yield_many(:infinity)
    end)
  end

  def to_start(config) do
    tasks =
      :ets.match_object(config.table, {{:_, :_, :_}, :_})
      |> Enum.map(fn neuron ->
        {key, _n} = neuron
        Task.async(Neuron, :to_start, [key, config])
      end)

    Task.yield_many(tasks, :infinity)
  end
end
