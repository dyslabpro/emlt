defmodule Emlt.NN.Storage.Pool do
  @moduledoc false
  use Supervisor

  @pool_name :storage_worker_pool
  @pool_size 20
  @pool_max_overflow 2


  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(opts) do

    pool_opts = [
      name: {:local, @pool_name},
      worker_module: Emlt.NN.StorageWorker,
      size: @pool_size,
      max_overflow: @pool_max_overflow
    ]

    children = [
      :poolboy.child_spec(
        @pool_name,
        pool_opts,
        opts
      )
    ]

    supervise(children, strategy: :one_for_one, name: __MODULE__)
  end
end