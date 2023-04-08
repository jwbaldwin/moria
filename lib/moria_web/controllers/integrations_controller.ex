defmodule MoriaWeb.IntegrationsController do
  @moduledoc """
  Controller that verifies integration OAuth requests
  """
  use MoriaWeb, :controller
  @shopify_client_id Application.compile_env(:shopify, :client_id)
  @shopify_scopes Application.compile_env(:shopify, :scopes)

  def verify(conn, %{"hmac" => provided_hmac_binary, "shop" => shop} = params) do
    hmac_key = Application.get_env(:shopify, :client_secret)

    query_params = Map.delete(params, "hmac")

    # Sort the query parameters alphabetically by key
    query_params =
      query_params
      |> Map.to_list()
      |> Enum.map(fn {k, v} -> "#{k}=#{v}" end)
      |> Enum.join("&")

    # Generate the expected hmac
    generated_hmac_binary =
      :hmac
      |> :crypto.mac(:sha256, hmac_key, query_params)
      |> Base.encode16()

    # Compare the provided hmac to the generated hmac
    is_request_valid? = provided_hmac_binary == generated_hmac_binary

    if is_request_valid? do
      redirect(conn, external: build_redirect_url(shop))
    else
      conn
      |> put_status(:bad_request)
      |> json(%{message: "Request is not valid."})
    end
  end

  defp build_redirect_url(shop) do
    # this needs to be more variable
    redirect_uri = "https://e552-138-88-63-219.ngrok.io/integrations"

    # 3xx redirect to the URL. During the redirect, set a signed cookie with the nonce value from the URL.
    nonce = :crypto.strong_rand_bytes(16)

    "https://#{shop}.myshopify.com/admin/oauth/authorize?client_id=#{@shopify_client_id}&scope=#{@shopify_scopes}&redirect_uri=#{redirect_uri}&state=#{nonce}&grant_options[]=per-user"
  end
end
