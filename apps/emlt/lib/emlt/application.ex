defmodule Emlt.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    _neurons = :ets.new(:neurons, [:set, :public, :named_table, read_concurrency: true, write_concurrency: true])
    _neurons = :ets.new(:neurons_activated, [:set, :public, :named_table, read_concurrency: true, write_concurrency: true])
    _neuron_connection = :ets.new(:neuron_connections, [:set, :public, :named_table, read_concurrency: true, write_concurrency: true])

    children = [
      #Emlt.NN.Neuron.Pool,
      Emlt.NN.Storage.Pool,
      Emlt.NN.Network
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Emlt.Supervisor)
  end
end
