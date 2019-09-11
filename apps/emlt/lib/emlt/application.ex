defmodule Emlt.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Emlt.NN.Neuron.Pool,
      Emlt.NN.Storage,
      Emlt.NN.Network
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Emlt.Supervisor)
  end
end
