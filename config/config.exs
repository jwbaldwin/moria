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

config :shopifex,
  repo: Moria.Repo,
  app_name: "Kept Retention",
  web_module: MoriaWeb,
  shop_schema: Moria.ShopifyShops.ShopifyShop,
  plan_schema: Moria.ShopifyShops.ShopifyPlan,
  grant_schema: Moria.ShopifyShops.ShopifyGrant,
  payment_guard: Moria.ShopifyPaymentGuard,
  redirect_uri: "https://5d3c-96-241-47-175.ngrok-free.app/auth/install",
  reinstall_uri: "https://5d3c-96-241-47-175.ngrok-free.app/auth/update",
  webhook_uri: "https://5d3c-96-241-47-175.ngrok-free.app/webhook",
  payment_redirect_uri: "https://5d3c-96-241-47-175.ngrok-free.app/payment/complete",
  scopes: "read_customers,read_reports,read_inventory,read_all_orders,read_orders,read_products",
  # TODO: update
  api_key: "52eea89b92c2ac05d1ca95500c88d251",
  # TODO: update
  secret: "c7f9530194695d91445f503bb3c3659a",
  # These are automatically subscribed on a store upon install
  webhook_topics: ["app/uninstalled"]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
