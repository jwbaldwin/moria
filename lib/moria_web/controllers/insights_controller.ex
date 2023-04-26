defmodule MoriaWeb.InsightsController do
  use MoriaWeb, :controller

  require Logger

  alias Moria.Integrations

  action_fallback MoriaWeb.FallbackController

  def orders(%{assigns: %{current_user: user}} = conn, _params) do
    Logger.info("Fetching orders")

    with {:ok, integration} <- Integrations.get_by_user(user),
         orders <- Integrations.list_all_orders(integration.id) do
      json(conn, %{data: orders})
    end
  end

  def products(%{assigns: %{current_user: user}} = conn, _params) do
    Logger.info("Fetching products")

    with {:ok, integration} <- Integrations.get_by_user(user),
         products <- Integrations.list_all_products(integration.id) do
      json(conn, %{data: products})
    end
  end

  def customers(%{assigns: %{current_user: user}} = conn, _params) do
    Logger.info("Fetching customers")

    with {:ok, integration} <- Integrations.get_by_user(user),
         customers <- Integrations.list_all_customers(integration.id) do
      json(conn, %{data: customers})
    end
  end
end
