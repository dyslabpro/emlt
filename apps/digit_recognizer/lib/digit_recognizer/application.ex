defmodule DigitRecognizer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    config = Application.fetch_env!(:digit_recognizer, :nn)
    :ets.new(config.table, [
      :set,
      :public,
      :named_table,
      read_concurrency: true,
      write_concurrency: true
    ])
    children = [
      # Starts a worker by calling: Titanik.Worker.start_link(arg)
      # {Titanik.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DigitRecognizer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
