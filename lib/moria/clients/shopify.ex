defmodule Moria.Clients.Shopify do
  alias Moria.Integrations.Integration

  def orders(client, full_link), do: Tesla.get(client, full_link)

  def orders(client) do
    fields =
      ~w(created_at customer email id line_items name number order_number processed_at source_url total_price updated_at user_id)
      |> Enum.join(",")

    Tesla.get(
      client,
      "orders.json?fields=#{fields}"
    )
  end

  def products(client, full_link), do: Tesla.get(client, full_link)

  def products(client) do
    fields =
      ~w(body_html created_at handle id options product_type published_at status title updated_at vendor)
      |> Enum.join(",")

    Tesla.get(
      client,
      "products.json?fields=#{fields}"
    )
  end

  def customers(client, full_link), do: Tesla.get(client, full_link)

  def customers(client) do
    fields =
      ~w(created_at email email_marketing_consent first_name id last_name phone sms_marketing_consent total_spent updated_at verified_email)
      |> Enum.join(",")

    Tesla.get(
      client,
      "customers.json?fields=#{fields}"
    )
  end

  @doc """
  Build dynamic client based on runtime arguments
  """
  def client(%Integration{shop: shop, access_token: access_token}) do
    middleware = [
      {Tesla.Middleware.BaseUrl, "https://#{shop}.myshopify.com/admin/api/2023-04"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"X-Shopify-Access-Token", access_token}]}
    ]

    Tesla.client(middleware)
  end
end