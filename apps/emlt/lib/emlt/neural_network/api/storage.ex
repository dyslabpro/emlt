defmodule Emlt.NN.Storage do
  @moduledoc """
    This is Api for neuron module
  """
 
  @pool_name :storage_worker_pool

  

  def insert(opts) do
    poolboy_exec(:insert, opts, :cast)
  end

  def get(opts) do
    poolboy_exec(:lookup, opts, :call)
  end

  def update(opts) do
    poolboy_exec(:update, opts, :call)
  end

  def insert_nc(opts) do
    poolboy_exec(:insert_nc, opts, :cast)
  end

  def get_nc(opts) do
    poolboy_exec(:lookup_nc, opts, :call)
  end

  def update_nc(opts) do
    poolboy_exec(:update_nc, opts, :call)
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

  
end
