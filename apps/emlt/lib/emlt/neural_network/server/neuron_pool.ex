defmodule Emlt.NN.Neuron.Pool do
    @moduledoc false
    use Supervisor
  
    @pool_name :neuron_worker_pool_
    @pool_size 2000
    @pool_max_overflow 200

  
    def start_link(opts \\ []) do
      Supervisor.start_link(__MODULE__, opts)
    end
  
    def init(opts) do
  
      pool_opts = [
        name: {:local, get_pool_name(opts)},
        worker_module: Emlt.NN.NeuronWorker,
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

    defp get_pool_name(layer) do
       "neuron_worker_pool_#{layer}" |> String.to_atom
    end
  end