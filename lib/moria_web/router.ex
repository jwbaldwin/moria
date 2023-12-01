defmodule MoriaWeb.Router do
  use MoriaWeb, :router

  import Shopifex.Plug, only: [put_shop_in_session: 2]

  require ShopifexWeb.Routes

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {MoriaWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(Shopifex.Plug.LoadInIframe)
    plug(:put_shop_in_session)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  ShopifexWeb.Routes.pipelines()

  # Include all auth (when Shopify requests to render your app in an iframe), installation and update routes
  ShopifexWeb.Routes.auth_routes(MoriaWeb.ShopifyAuthController)

  # Include all payment routes
  ShopifexWeb.Routes.payment_routes(MoriaWeb.ShopifyPaymentController)

  # Endpoints accessible within the Shopify admin panel iFrame.
  # Don't include this scope block if you are creating a SPA.
  scope "/", MoriaWeb do
    pipe_through([:browser])

    get "/privacy", PolicyController, :privacy
  end

  scope "/", MoriaWeb do
    pipe_through([:browser, :shopify_session])

    live_session :default,
      session: {MoriaWeb.ShopifyInfo, :session, []},
      on_mount: [{MoriaWeb.ShopifyInfo, :assign_shop}] do
      live("/", HomeLive.Index, :index)

      live("/top-customers/:id", TopCustomersLive, :index)
      live("/top-products/:id", TopProductsLive, :index)
      live("/new-products/:id", NewProductsLive, :index)
    end

    # get("/", PageController, :home)
  end

  # Make your webhook endpoint look like this
  scope "/webhook", MoriaWeb do
    pipe_through([:shopify_webhook])

    post("/", ShopifyWebhookController, :action)
  end

  # Place your admin link endpoints in here. TODO: create this controller
  scope "/admin-links", MoriaWeb do
    pipe_through([:shopify_admin_link])

    # get "/do-a-thing", ShopifyAdminLinkController, :do_a_thing
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through([:fetch_session, :protect_from_forgery])

      live_dashboard("/dashboard", metrics: MoriaWeb.Telemetry)
      forward("/gallery", MoriaWeb.Emails.Gallery)
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through([:fetch_session, :protect_from_forgery])

      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
