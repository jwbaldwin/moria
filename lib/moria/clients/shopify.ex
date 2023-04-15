defmodule Moria.Clients.Shopify do
  alias Moria.Integrations.Integration

  def orders(client) do
    fields =
      ~w(created_at,updated_at,id,name,total_price,user_id,source_url,processed_at,number,order_number,name,line_items,email,customer)
      |> Enum.join(",")

    Tesla.get(
      client,
      "orders.json?fields=#{fields}"
    )
  end

  # build dynamic client based on runtime arguments
  def client(%Integration{shop: shop, access_token: access_token}) do
    middleware = [
      {Tesla.Middleware.BaseUrl, "https://#{shop}.myshopify.com/admin/api/2023-04"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"X-Shopify-Access-Token", access_token}]}
    ]

    Tesla.client(middleware)
  end
end
