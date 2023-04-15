defmodule Moria.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Moria.Repo,
      # Start the Telemetry supervisor
      MoriaWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Moria.PubSub},
      # Start the Endpoint (http/https)
      MoriaWeb.Endpoint,
      # Start a worker by calling: Moria.Worker.start_link(arg)
      # {Moria.Worker, arg}
      {Oban, Application.fetch_env!(:moria, Oban)},
      {Finch, name: APIClient}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Moria.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MoriaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
