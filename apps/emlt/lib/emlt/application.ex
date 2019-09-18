defmodule Emlt.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    _neurons = :ets.new(:neurons, [:set, :public, :named_table])
    _neuron_connection = :ets.new(:neuron_connections, [:set, :public, :named_table])

    children = [

      Supervisor.child_spec({Emlt.NN.Neuron.Pool, "1"}, id: :my_worker_1),
      Supervisor.child_spec({Emlt.NN.Neuron.Pool, "2"}, id: :my_worker_2),
      Supervisor.child_spec({Emlt.NN.Neuron.Pool, "3"}, id: :my_worker_3),

      Emlt.NN.Storage.Pool,
      Emlt.NN.Network
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Emlt.Supervisor)
  end
end
