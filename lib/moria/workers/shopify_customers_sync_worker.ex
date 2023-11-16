defmodule Moria.Workers.ShopifyCustomersSyncWorker do
  use Oban.Worker, queue: :default, max_attempts: 3, tags: ["shopify"]

  alias Moria.Clients.Shopify
  alias Moria.Integrations
  alias Moria.ShopifyShops.ShopifyCustomer
  alias Moria.Shopify.Services.NextLinkExtractor
  alias Moria.Workers.ShopifyOrdersSyncWorker

  @impl Oban.Worker
  def perform(%Oban.Job{args: params}) do
    do_perform(params)
  end

  def do_perform(%{"shop" => shop, "link" => link}) do
    shop = Shopifex.Shops.get_shop_by_url(shop)
    client = Shopify.client(shop)

    with {:ok, response} <- Shopify.customers(client, %{link: link}),
         :ok <-
           Integrations.bulk_insert_resource(
             ShopifyCustomer,
             response.body["customers"],
             shop.id
           ) do
      maybe_enqueue_worker(shop, response.headers, shop.last_synced)
    end
  end

  # The first run
  def do_perform(%{"shop" => shop, "since" => since}) do
    shop = Shopifex.Shops.get_shop_by_url(shop)
    client = Shopify.client(shop)

    with {:ok, response} <- Shopify.customers(client, %{since: since}),
         :ok <-
           Integrations.bulk_insert_resource(
             ShopifyCustomer,
             response.body["customers"],
             shop.id
           ) do
      maybe_enqueue_worker(shop, response.headers, shop.last_synced)
    end
  end

  defp maybe_enqueue_worker(shop, headers, since) do
    case NextLinkExtractor.call(headers) do
      nil ->
        # All customers loaded, import orders and attach
        Oban.insert(ShopifyOrdersSyncWorker.new(%{shop: shop.url, since: since}))

      link ->
        %{shop: shop.url, link: link}
        |> new()
        |> Oban.insert()
    end
  end
end
