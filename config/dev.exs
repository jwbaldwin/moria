import Config

# Configure your database
config :moria, Moria.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "moria_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with esbuild to bundle .js and .css sources.
config :moria, MoriaWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "yPdGDbQ27bHtqxQ3pVXZkDXZT+gs7PwquOI+cMHuc8ucIdpM7Q9lEoXc2MsnQJu3",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]

# Watch static and templates for browser reloading.
config :moria, MoriaWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/moria_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# Enable dev routes for dashboard and mailbox
config :moria, dev_routes: true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Include HEEx debug annotations as HTML comments in rendered markup
config :phoenix_live_view, :debug_heex_annotations, true

config :shopifex,
  repo: Moria.Repo,
  app_name: "Kept Retention",
  web_module: MoriaWeb,
  shop_schema: Moria.ShopifyShops.ShopifyShop,
  plan_schema: Moria.ShopifyShops.ShopifyPlan,
  grant_schema: Moria.ShopifyShops.ShopifyGrant,
  payment_guard: Moria.ShopifyPaymentGuard,
  redirect_uri: "https://c9ab-96-241-47-175.ngrok-free.app/auth/install",
  reinstall_uri: "https://c9ab-96-241-47-175.ngrok-free.app/auth/update",
  webhook_uri: "https://c9ab-96-241-47-175.ngrok-free.app/webhook",
  payment_redirect_uri: "https://c9ab-96-241-47-175.ngrok-free.app/payment/complete",
  scopes: "read_customers,read_reports,read_inventory,read_all_orders,read_orders,read_products",
  api_key: System.get_env("SHOPIFY_API_KEY"),
  secret: System.get_env("SHOPIFY_API_SECRET"),
  # These are automatically subscribed on a store upon install
  webhook_topics: ["app/uninstalled"]

# CRON workers, configured to @hourly for testing
config :moria, Oban,
  plugins: [
    {Oban.Plugins.Cron,
     crontab: [
       # {"@hourly", Moria.Insights.Services.EnqueueWeeklyBriefEmailWorker}
       {"@daily", Moria.Integrations.Services.EnqueueWeeklySyncWorker}
     ]}
  ]
