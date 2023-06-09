# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :moria,
  ecto_repos: [Moria.Repo]

# Configures the endpoint
config :moria, MoriaWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: MoriaWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Moria.PubSub,
  live_view: [signing_salt: "tlg8TYXh"]

# Oban configuration
# 30 days before pruning
config :moria, Oban,
  repo: Moria.Repo,
  plugins: [{Oban.Plugins.Pruner, max_age: 43200}],
  queues: [default: 10]

# Tesla configuration
config :tesla, adapter: {Tesla.Adapter.Finch, name: APIClient}

# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
config :moria, Moria.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :moria, :pow,
  user: Moria.Users.User,
  repo: Moria.Repo,
  extensions: [PowResetPassword, PowEmailConfirmation, PowPersistentSession],
  controller_callbacks: Pow.Extension.Phoenix.ControllerCallbacks,
  mailer_backend: MoriaWeb.Emails.Mailer

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
