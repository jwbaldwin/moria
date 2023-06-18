defmodule Moria.Integrations.Services.AttachAndCreateUser do
  @moduledoc """
  Here we grab the shop owner and create an account for them.
  """

  alias Moria.Clients.Shopify

  @spec call(map()) :: {:ok, any()}
  def call(integration_params) do
    client = Shopify.raw_client(integration_params)

    with {:ok, response} <- Shopify.shop_info(client) do
      {:ok,
       %{
         email: response.body["shop"]["email"],
         name: response.body["shop"]["shop_owner"],
         password: response.body["shop"]["email"],
         password_confirmation: response.body["shop"]["email"]
       }}
    end
  end
end
