import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/moria start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :moria, MoriaWeb.Endpoint, server: true
end

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []

  config :moria, Moria.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "app.gokept.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :moria, MoriaWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  ## Configuring the mailer
  config :moria, Moria.Mailer,
    adapter: Swoosh.Adapters.Sendinblue,
    api_key: System.get_env("BREVO_API_KEY")

  config :swoosh,
    api_client: Swoosh.ApiClient.Finch,
    finch_name: APIClient

  ## Configuring shopifex
  config :shopifex,
    repo: Moria.Repo,
    app_name: "Kept Retention",
    web_module: MoriaWeb,
    shop_schema: Moria.ShopifyShops.ShopifyShop,
    plan_schema: Moria.ShopifyShops.ShopifyPlan,
    grant_schema: Moria.ShopifyShops.ShopifyGrant,
    payment_guard: Moria.ShopifyPaymentGuard,
    redirect_uri: "https://app.gokept.com/auth/install",
    reinstall_uri: "https://app.gokept.com/auth/update",
    webhook_uri: "https://app.gokept.com/webhook",
    payment_redirect_uri: "https://app.gokept.com/payment/complete",
    scopes:
      "read_customers,read_reports,read_inventory,read_all_orders,read_orders,read_products",
    api_key: System.get_env("SHOPIFY_API_KEY"),
    secret: System.get_env("SHOPIFY_API_SECRET"),
    # These are automatically subscribed on a store upon install
    webhook_topics: ["app/uninstalled"]

  config :moria, Oban,
    plugins: [
      {Oban.Plugins.Cron,
       crontab: [
         {"0 4 * * MON", Moria.Insights.Services.EnqueueWeeklyBriefEmailWorker}
       ]}
    ]
end
