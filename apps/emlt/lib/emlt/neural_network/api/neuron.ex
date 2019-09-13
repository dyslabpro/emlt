defmodule Emlt.NN.Neuron do


  @moduledoc """
    This is Api for neuron module
  """
  alias Emlt.NN.{Neuron, Network, NeuronConnection, Storage}

  @pool_name :neuron_worker_pool

  def preload_inbound_connections(opts) do
    {key, neuron} = opts

    prev_layer =
      case neuron.z do
        1 ->
          get_first_layers_keys()

        _ ->
          get_prev_layers_keys(neuron.x, neuron.y, neuron.z)
      end

    inbound_connections =
      Enum.map(prev_layer, fn nc ->
        NeuronConnection.get([nc, {neuron.x, neuron.y, neuron.z}]) |> hd
      end)

    neuron = neuron |> Map.merge(%{inbound_connections: inbound_connections})
    {key, neuron}
  end

  def insert(opts) do
    Storage.insert(opts)
  end

  def get(opts) do
    Storage.get(opts) |> hd
  end

  def update(opts) do
    Storage.update(opts)
  end

  def signal(opts) do
    poolboy_exec(:signal, opts, :cast)
  end

  defp poolboy_exec(command_name, opts, op) do
    case op do
      :call ->
        :poolboy.transaction(
          @pool_name,
          fn pid -> GenServer.call(pid, {command_name, opts}) end,
          :infinity
        )

      :cast ->
        :poolboy.transaction(
          @pool_name,
          fn pid -> GenServer.cast(pid, {command_name, opts}) end,
          :infinity
        )
    end
  end

  def get_next_layers(x, y, z) do
    for i <- 1..28,
        j <- 1..28,
        into: [],
        do: %{
          key: [{x, y, z}, {i, j, z + 1}],
          weight: Enum.random(-100..100) / 10,
          signal: 0
        }
  end

  def get_prev_layers(x, y, z) do
    for i <- 1..28,
        j <- 1..28,
        into: [],
        do: %{
          key: [{x, y, z}, {i, j, z - 1}],
          weight: Enum.random(-100..100) / 10,
          signal: 0
        }
  end

  def get_prev_layers_keys(_x, _y, z) do
    for i <- 1..28,
        j <- 1..28,
        into: [],
        do: {i, j, z - 1}
  end

  def get_last_layers(x, y, z) do
    for x <- 0..9,
        into: [],
        do: %{
          key: [{x, y, z}, {x, 1, 3}],
          weight: Enum.random(-100..100) / 10,
          signal: 0
        }
  end

  def get_first_layers_keys() do
    [
      {0, 0, 0}
    ]
  end
end
