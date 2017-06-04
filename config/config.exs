# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :one2many,
  ecto_repos: [One2many.Repo]

# Configures the endpoint
config :one2many, One2many.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "lCe0xRuW2/G04f4830pJsjy90SyaAF1xqmcBwFqrmXIa8qqLRlMHQ2PFpHgd8MKE",
  render_errors: [view: One2many.ErrorView, accepts: ~w(html json)],
  pubsub: [name: One2many.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
