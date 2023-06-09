defmodule Moria.Workers.ShopifyCustomersSyncWorker do
  use Oban.Worker, queue: :default, max_attempts: 3, tags: ["shopify"]

  alias Moria.Clients.Shopify
  alias Moria.Integrations
  alias Moria.Integrations.ShopifyCustomer
  alias Moria.Shopify.Services.NextLinkExtractor
  alias Moria.Workers.ShopifyOrdersSyncWorker

  @impl Oban.Worker
  def perform(%Oban.Job{args: params}) do
    do_perform(params)
  end

  def do_perform(%{"shop" => shop, "link" => link}) do
    {:ok, integration} = Integrations.get_by_shop(shop)
    client = Shopify.client(integration)

    with {:ok, response} <- Shopify.customers(client, %{link: link}),
         :ok <-
           Integrations.bulk_insert_resource(
             ShopifyCustomer,
             response.body["customers"],
             integration.id
           ) do
      maybe_enqueue_worker(shop, response.headers, integration.last_synced)
    end
  end

  # The first run
  def do_perform(%{"shop" => shop, "since" => since}) do
    {:ok, integration} = Integrations.get_by_shop(shop)
    client = Shopify.client(integration)

    with {:ok, response} <- Shopify.customers(client, %{since: since}),
         :ok <-
           Integrations.bulk_insert_resource(
             ShopifyCustomer,
             response.body["customers"],
             integration.id
           ) do
      maybe_enqueue_worker(shop, response.headers, integration.last_synced)
    end
  end

  defp maybe_enqueue_worker(shop, headers, since) do
    case NextLinkExtractor.call(headers) do
      nil ->
        # All customers loaded, import orders and attach
        Oban.insert(ShopifyOrdersSyncWorker.new(%{shop: shop, since: since}))

      link ->
        %{shop: shop, link: link}
        |> new()
        |> Oban.insert()
    end
  end
end
