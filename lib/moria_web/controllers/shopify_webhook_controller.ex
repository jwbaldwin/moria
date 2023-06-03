defmodule MoriaWeb.ShopifyWebhookController do
  use MoriaWeb, :controller

  require Logger

  def data_request(conn, params) do
    Logger.info("Recieved a data_request request with params: #{inspect(params)}")
    render(conn, :"200")
  end

  def customers_redact(conn, params) do
    Logger.info("Recieved a customers_redact request with params: #{inspect(params)}")
    render(conn, :"200")
  end

  def shop_redact(conn, params) do
    Logger.info("Recieved a shop_request request with params: #{inspect(params)}")
    render(conn, :"200")
  end
end
