defmodule RetentionWeb.ShopifyWebhookController do
  use RetentionWeb, :controller
  use ShopifexWeb.WebhookController

  require Logger

  @moduledoc """
  For available callbacks, see https://hexdocs.pm/shopifex/ShopifexWeb.WebhookController.html
  """

  # add as many handle_topic/3 functions here as you like! This basic one handles app uninstallation
  def handle_topic(conn, shop, "app/uninstalled") do
    Shopifex.Shops.delete_shop(shop)

    conn
    |> send_resp(200, "success")
  end

  # Mandatory Shopify shop data erasure GDPR webhook. Simply delete the shop record
  def handle_topic(conn, shop, "shop/redact") do
    Shopifex.Shops.delete_shop(shop)

    conn
    |> send_resp(204, "")
  end

  # Mandatory Shopify customer data erasure GDPR webhook. Simply delete the shop (customer) record
  def handle_topic(conn, shop, "customers/redact") do
    Shopifex.Shops.delete_shop(shop)

    conn
    |> send_resp(204, "")
  end

  # Mandatory Shopify customer data request GDPR webhook.
  def handle_topic(conn, shop, "customers/data_request") do
    # Send an email of the shop data to the customer.
    Logger.warning("customers/data_request received for #{shop} - send email of customer data.")

    conn
    |> send_resp(202, "Accepted")
  end
end
