defmodule MoriaWeb.IntegrationsController do
  @moduledoc """
  Controller that verifies integration OAuth requests
  """
  use MoriaWeb, :controller

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
    client_id = Application.get_env(:shopify, :client_id)
    scopes = "read_customers,read_reports,read_inventory,read_all_orders,read_products"
    # this needs to be more variable
    redirect_uri = "https://e552-138-88-63-219.ngrok.io/integrations"
    # how does this work exactly? we need to verify this same value again?
    nonce = :crypto.strong_rand_bytes(16)
    access_mode = "per-user"

    "https://#{shop}.myshopify.com/admin/oauth/authorize?client_id=#{client_id}&scope=#{scopes}&redirect_uri=#{redirect_uri}&state=#{nonce}&grant_options[]=#{access_mode}"
  end
end
