# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

config :titanik,
  nn: %{
    table: :titanik_neurons,
    mode: :learn,
    backup: 'titanik_neurons.dets',
    layers: [
      %{
        size: {6, 6},
        size_nc: 10,
        nc_weights: -5..5,
        z_index: 2,
        targets: nil,
        role: "hidden",
        rate: 0.1
      },      
      %{
        size: {1, 2},
        size_nc: 6,
        nc_weights: -5..5,
        z_index: 3,
        targets: [0, 1],
        role: "out",
        rate: 0.1
      }
    ]
  }
