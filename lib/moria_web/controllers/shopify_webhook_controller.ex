defmodule MoriaWeb.ShopifyWebhookController do
  use MoriaWeb, :controller

  require Logger

  def data_request(conn, params) do
    Logger.info("Recieved a data_request request with params: #{inspect(params)}")
    handle_response(conn)
  end

  def customers_redact(conn, params) do
    Logger.info("Recieved a customers_redact request with params: #{inspect(params)}")
    handle_response(conn)
  end

  def shop_redact(conn, params) do
    Logger.info("Recieved a shop_request request with params: #{inspect(params)}")
    handle_response(conn)
  end

  defp handle_response(conn) do
    with [hmac] <- get_req_header(conn, "x-shopify-hmac-sha256"),
         raw_params <- conn.assigns[:raw_body],
         true <- verify_hmac(hmac, raw_params) do
      conn
      |> put_status(:ok)
      |> json(%{})
    else
      _error ->
        conn
        |> put_status(:unauthorized)
        |> json(%{})
    end
  end

  defp verify_hmac(hmac, params) when is_nil(hmac) or is_nil(params), do: false

  defp verify_hmac(hmac, params) do
    try do
      hmac_key = Application.get_env(:tiger, :shopify_client_secret)

      # Generate the expected hmac
      generated_hmac_binary =
        :hmac
        |> :crypto.mac(:sha256, hmac_key, params)
        |> Base.encode64(case: :lower)

      # Compare the provided hmac to the generated hmac
      Plug.Crypto.secure_compare(hmac, generated_hmac_binary)
    rescue
      _error -> false
    end
  end
end
