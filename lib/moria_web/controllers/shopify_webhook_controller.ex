defmodule MoriaWeb.ShopifyWebhookController do
  use MoriaWeb, :controller

  require Logger

  def data_request(conn, params) do
    Logger.info("Recieved a data_request request with params: #{inspect(params)}")
    handle_response(conn, params)
  end

  def customers_redact(conn, params) do
    Logger.info("Recieved a customers_redact request with params: #{inspect(params)}")
    handle_response(conn, params)
  end

  def shop_redact(conn, params) do
    Logger.info("Recieved a shop_request request with params: #{inspect(params)}")
    handle_response(conn, params)
  end

  defp handle_response(conn, params) do
    [hmac] = get_req_header(conn, "x-shopify-hmac-sha256")
    raw_params = conn.assigns[:raw_body]

    if verify_hmac(hmac, raw_params) do
      conn
      |> put_status(:ok)
      |> json(%{})
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{})
    end
  end

  defp verify_hmac(hmac, params) do
    hmac_key = Application.get_env(:shopify, :client_secret)

    # Generate the expected hmac
    generated_hmac_binary =
      :hmac
      |> :crypto.mac(:sha256, hmac_key, params)
      |> Base.encode64(case: :lower)

    # Compare the provided hmac to the generated hmac
    Plug.Crypto.secure_compare(hmac, generated_hmac_binary)
  end
end
