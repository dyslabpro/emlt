defmodule Emlt.NN.Config do
  @moduledoc """
  Spec for config of Neural network.
  """
  @type layer_config :: %{
          size: {integer, integer},
          size_nc: integer,
          nc_weights: Range.t(),
          z_index: integer,
          targets: any(),
          role: String.t(),
          rate: float
        }
  @typedoc """
  type of config for Neural network.
  """

  @type nn_config :: %__MODULE__{
          table: atom(),
          mode: atom(),
          backup: atom(),
          layers: list(layer_config)
        }

  @type t :: nn_config

  defstruct layer_config: %{},
            size: {nil, nil},
            size_nc: nil,
            table: nil,
            mode: nil,
            backup: nil,
            layers: []
end
