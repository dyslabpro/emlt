defmodule Emlt.NN.Neuron do
  @pool_name :neuron_worker_pool

  def insert(attr) do
    :poolboy.transaction(
      @pool_name,
      fn pid -> GenServer.cast(pid, {:insert, attr}) end,
      :infinity
    )
  end
  
  def lookup(attr) do
    :poolboy.transaction(
      @pool_name,
      fn pid -> GenServer.call(pid, {:lookup, attr}) end,
      :infinity
    )
  end

  def update(attr) do
    :poolboy.transaction(
      @pool_name,
      fn pid -> GenServer.call(pid, {:update, attr}) end,
      :infinity
    )
  end

  def insert_nc(attr) do
    :poolboy.transaction(
      @pool_name,
      fn pid -> GenServer.cast(pid, {:insert_nc, attr}) end,
      :infinity
    )
  end

  def lookup_nc(attr) do
    :poolboy.transaction(
      @pool_name,
      fn pid -> GenServer.call(pid, {:lookup_nc, attr}) end,
      :infinity
    )
  end
end
