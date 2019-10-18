defmodule Emlt.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false 
    

    children = [      
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Emlt.Supervisor)
  end
end
