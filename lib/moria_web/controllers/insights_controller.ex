defmodule MoriaWeb.InsightsController do
  use MoriaWeb, :controller
  use MoriaWeb.CurrentUser

  require Logger

  alias Moria.Integrations
  alias Moria.Insights.Handlers.Brief

  action_fallback MoriaWeb.FallbackController

  def weekly_brief(conn, _params, user) do
    with {:ok, brief} <- Brief.weekly_brief(user) do
      json(conn, %{brief: brief})
    end
  end

  def orders(conn, _params, user) do
    Logger.info("Fetching orders")

    with {:ok, integration} <- Integrations.get_by_user(user),
         orders <- Integrations.list_all_orders(integration.id) do
      json(conn, %{data: orders})
    end
  end

  def products(conn, _params, user) do
    Logger.info("Fetching products")

    with {:ok, integration} <- Integrations.get_by_user(user),
         products <- Integrations.list_all_products(integration.id) do
      json(conn, %{data: products})
    end
  end

  def customers(conn, _params, user) do
    Logger.info("Fetching customers")

    with {:ok, integration} <- Integrations.get_by_user(user),
         customers <- Integrations.list_all_customers(integration.id) do
      json(conn, %{data: customers})
    end
  end
end
