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

config :digit_recognizer,
  nn: %{
    table: :digit_recognizer_neurons,
    mode: :learn,
    backup: 'neurons-6.dets',
    layers: [
      %{
        size: {17, 17},
        size_nc: 28,
        nc_weights: -5..5,
        z_index: 2,
        targets: nil,
        role: "hidden",
        rate: 0.1
      },
      %{
        size: {10, 10},
        size_nc: 17,
        nc_weights: -5..5,
        z_index: 3,
        targets: nil,
        role: "hidden",
        rate: 0.1
      },
      %{
        size: {1, 10},
        size_nc: 10,
        nc_weights: -5..5,
        z_index: 4,
        targets: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
        role: "out",
        rate: 0.1
      }
    ]
  }
