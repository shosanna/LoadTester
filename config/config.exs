# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config
config :load_tester, master_node: :"a@127.0.0.1"
config :load_tester, slave_nodes: [
                                    :"b@127.0.0.1",
                                    :"c@127.0.0.1",
                                    :"d@127.0.0.1"
                                  ]

# You can configure for your application as:
#
#     config :load_tester, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:load_tester, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info

