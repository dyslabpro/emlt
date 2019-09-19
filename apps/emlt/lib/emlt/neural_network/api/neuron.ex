defmodule Emlt.NN.Neuron do
  @moduledoc """
    This is Api for neuron module
  """
  alias Emlt.NN.{Neuron, Network, NeuronConnection, Storage}
  @pool_name :neuron_worker_pool

  def preload_inbound_connections(neuron) do
    list = Storage.match_nc({[:_, {neuron.x, neuron.y, neuron.z}], :_})
    inbound_connections = list |> Enum.map(fn inc -> elem(inc, 1) end)

    neuron |> Map.merge(%{inbound_connections: inbound_connections})
  end

  def preload_outbound_connections(neuron) do
    list = Storage.match_nc({[{neuron.x, neuron.y, neuron.z}, :_], :_})
    outbound_connections = list |> Enum.map(fn inc -> elem(inc, 1) end)

    neuron |> Map.merge(%{outbound_connections: outbound_connections})
  end

  def insert(opts) do
    Storage.insert(opts)
  end

  def get(opts) do
    {_key, neuron} = Storage.get(opts) |> hd
    neuron
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
          weight: Enum.random(-14..14),
          signal: 0
        }
  end

  def get_prev_layers(x, y, z) do
    for i <- 1..28,
        j <- 1..28,
        into: [],
        do: %{
          key: [{x, y, z}, {i, j, z - 1}],
          weight: Enum.random(-14..14),
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
    for xl <- 0..9,
        into: [],
        do: %{
          key: [{x, y, z}, {xl, 1, 3}],
          weight: Enum.random(-14..14),
          signal: 0
        }
  end

  def get_first_layers_keys() do
    [
      {0, 0, 0}
    ]
  end

  def get_activated_value(neuron) do
    {key, n} = neuron
    n.activated_value
  end

  def init_weight() do
    # range = [-28/2 , 28/2]
  end
end
