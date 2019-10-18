defmodule Emlt.NN.Network do
  @moduledoc """
  Это хорошая документация.
  """
  
  alias Emlt.NN.{Neuron, Layer, Network}

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

  
  def learn(config, signal, target) do
    Network.signal(config, signal)
    # Layer.inspect(4, config)

    Network.delta(config, signal, target)
    Network.weight(config, signal, target)
    Network.to_start(config)

    :ok
  end

  def test(config, signal) do    
    Network.signal(config, signal)
    target = Layer.get_res(3, config)
    Emlt.NN.Network.to_start(config)
    target
  end

  def get_conf(config, layer) do
    config.layers
    |> Enum.filter(fn x -> x.z_index == layer end)
    |> hd
    |> Map.merge(%{
      table: config.table
    })
  end

  def signal(config, signal) do
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

  def delta(config, signal, target) do
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

  def weight(config, signal, target) do
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
