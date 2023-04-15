defmodule MoriaWeb.IntegrationsController do
  @moduledoc """
  Controller that verifies integration OAuth requests
  """
  use MoriaWeb, :controller

  require Logger

  alias Moria.Integrations

  action_fallback MoriaWeb.FallbackController

  def shopify(conn, params) do
    %{"auth_token_url" => auth_token_url, "scopes" => scopes, "shop" => shop} = params

    json_data =
      params
      |> Map.delete("auth_token_url")
      |> Map.delete("scopes")
      |> Map.delete("shop")

    with {:ok, %Req.Response{status: 200, body: body}} <-
           Req.post(auth_token_url, json: json_data),
         true <- verify_scopes(body, scopes),
         integration_params <- build_integration_params(body, shop),
         {:ok, _} <- Integrations.upsert_integration(integration_params) do
      conn
      |> put_status(:created)
      |> json(%{shop: shop})
    else
      {:ok, response} ->
        Logger.warn(response.body)
        {:error, :unauthorized}
    end
  end

  defp verify_scopes(%{"scope" => returned_scopes}, requested_scopes) do
    Enum.sort(String.split(returned_scopes, ",")) ==
      Enum.sort(String.split(requested_scopes, ","))
  end

  defp build_integration_params(%{"access_token" => access_token}, shop) do
    %{
      shop: shop,
      access_token: access_token,
      type: :shopify
    }
  end
end
