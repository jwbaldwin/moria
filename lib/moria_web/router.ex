defmodule MoriaWeb.Router do
  use MoriaWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug MoriaWeb.Auth.AuthPlug, otp_app: :moria
  end

  pipeline :api_protected do
    plug Pow.Plug.RequireAuthenticated, error_handler: MoriaWeb.Auth.ErrorHandler
  end

  get "/", MoriaWeb.HealthController, singleton: true, only: [:index]

  scope "/api", MoriaWeb do
    pipe_through :api

    resources "/registration", RegistrationController, singleton: true, only: [:create]
    resources "/session", SessionController, singleton: true, only: [:create, :delete]
    post "/session/renew", SessionController, :renew
  end

  scope "/api", MoriaWeb do
    pipe_through [:api, :api_protected]

    get "/integrations", IntegrationsController, :index
    post "/oauth/shopify", IntegrationsController, :shopify

    get "/insights/weekly-brief", InsightsController, :weekly_brief
    get "/insights/orders", InsightsController, :orders
    get "/insights/products", InsightsController, :products
    get "/insights/customers", InsightsController, :customers
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
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: MoriaWeb.Telemetry
      forward "/gallery", MoriaWeb.Emails.Gallery
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
