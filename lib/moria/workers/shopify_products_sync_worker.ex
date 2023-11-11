defmodule Moria.Workers.ShopifyProductsSyncWorker do
  use Oban.Worker, queue: :default, max_attempts: 3, tags: ["shopify"]

  alias Moria.Clients.Shopify
  alias Moria.Integrations
  alias Moria.ShopifyShops.ShopifyProduct
  alias Moria.Shopify.Services.NextLinkExtractor

  @impl Oban.Worker
  def perform(%Oban.Job{args: params}) do
    do_perform(params)
  end

  def do_perform(%{"shop" => shop, "link" => link}) do
    shop = Shopifex.Shops.get_shop_by_url(shop)
    client = Shopify.client(shop)

    with {:ok, response} <- Shopify.products(client, %{link: link}),
         :ok <-
           Integrations.bulk_insert_resource(
             ShopifyProduct,
             response.body["products"],
             shop.id
           ) do
      maybe_enqueue_worker(shop, response.headers)
    end
  end

  # The first run
  def do_perform(%{"shop" => shop, "since" => since}) do
    shop = Shopifex.Shops.get_shop_by_url(shop)
    client = Shopify.client(shop)

    with {:ok, response} <- Shopify.products(client, %{since: since}),
         :ok <-
           Integrations.bulk_insert_resource(
             ShopifyProduct,
             response.body["products"],
             shop.id
           ) do
      maybe_enqueue_worker(shop, response.headers)
    end
  end

  defp maybe_enqueue_worker(shop, headers) do
    case NextLinkExtractor.call(headers) do
      nil ->
        :ok

      link ->
        %{shop: shop.url, link: link}
        |> new()
        |> Oban.insert()
    end
  end
end
