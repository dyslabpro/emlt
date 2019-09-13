defmodule Emlt.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    _neurons = :ets.new(:neurons, [:set, :public, :named_table])
    _neuron_connection = :ets.new(:neuron_connections, [:set, :public, :named_table])
    children = [
      Emlt.NN.Neuron.Pool,
      Emlt.NN.Storage.Pool,
      Emlt.NN.Network
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Emlt.Supervisor)
  end
end
