defmodule MoriaWeb.IntegrationsController do
  @moduledoc """
  Controller that verifies integration OAuth requests
  """
  use MoriaWeb, :controller
  use MoriaWeb.CurrentUser

  require Logger

  alias Moria.Integrations
  alias Moria.Integrations.Services.AttachAndCreateUser
  alias Moria.Users

  action_fallback MoriaWeb.FallbackController

  def index(conn, _params, current_user) do
    integrations = Integrations.list_integrations(current_user)
    json(conn, %{integrations: integrations})
  end

  def shopify(conn, params, _) do
    %{"auth_token_url" => auth_token_url, "scopes" => scopes, "shop" => shop} = params

    json_data =
      params
      |> Map.delete("auth_token_url")
      |> Map.delete("scopes")
      |> Map.delete("shop")

    with {:ok, %Req.Response{status: 200, body: body}} <-
           Req.post(auth_token_url, json: json_data),
         true <- verify_scopes(body, scopes),
         {:ok, user, conn} <-
           maybe_create_user(conn, %{shop: shop, access_token: body["access_token"]}),
         integration_params <- build_integration_params(user.id, body, shop),
         {:ok, integration} <- Integrations.upsert_integration(integration_params) do
      Moria.EnqueueShopifySyncWorkers.call(integration)

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

  defp maybe_create_user(conn, params) do
    if conn.assigns.current_user do
      {:ok, conn, conn.assigns.current_user}
    else
      {:ok, user_params} = AttachAndCreateUser.call(params)

      case Users.get_user_by_email(user_params.email) do
        nil ->
          Pow.Plug.create_user(conn, user_params)

        user ->
          {:ok, user, conn}
      end
    end
  end

  defp build_integration_params(user_id, %{"access_token" => access_token}, shop) do
    %{
      shop: shop,
      access_token: access_token,
      type: :shopify,
      user_id: user_id
    }
  end
end
