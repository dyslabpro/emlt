defmodule Emlt.NN.Storage do
  use GenServer

  @doc """
  Запуск и линковка нашей очереди. Это вспомогательный метод.
  """
  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @doc """
  Функция обратного вызова для GenServer.init/1
  """
  def init(state) do
    neurons = :ets.new(:neurons, [:set, :public, :named_table])
    neuron_connection = :ets.new(:neuron_connections, [:set, :public, :named_table])
    state = [neurons, neuron_connection]

    {:ok, state}
  end
end
