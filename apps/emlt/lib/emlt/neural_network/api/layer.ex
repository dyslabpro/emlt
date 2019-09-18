defmodule Emlt.NN.Layer do
  alias Emlt.NN.{Layer, Storage, Neuron}

  def get(layer) do
    Storage.match({{:_, :_, layer}, :_})
  end

  def get_activated(layer) do
    layer
    |> Layer.get()
    |> Enum.filter(fn n ->
      Neuron.get_activated_value(n) > 0
    end)
  end


end
