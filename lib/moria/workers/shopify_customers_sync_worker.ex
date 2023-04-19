defmodule Moria.Workers.ShopifyCustomersSyncWorker do
  use Oban.Worker, queue: :default, max_attempts: 3, tags: ["shopify"]

  alias Moria.Clients.Shopify
  alias Moria.Integrations
  alias Moria.Integrations.ShopifyCustomer
  alias Moria.Shopify.Services.NextLinkExtractor

  @impl Oban.Worker
  def perform(%Oban.Job{args: params}) do
    do_perform(params)
  end

  def do_perform(%{"shop" => shop, "link" => link}) do
    {:ok, integration} = Integrations.get_by_shop(shop)
    client = Shopify.client(integration)

    with {:ok, response} <- Shopify.customers(client, link),
         :ok <-
           Integrations.bulk_insert_resource(
             ShopifyCustomer,
             response.body["customers"],
             integration.id
           ) do
      maybe_enqueue_worker(shop, response.headers)
    end
  end

  # The first run
  def do_perform(%{"shop" => shop}) do
    {:ok, integration} = Integrations.get_by_shop(shop)
    client = Shopify.client(integration)

    with {:ok, response} <- Shopify.customers(client),
         :ok <-
           Integrations.bulk_insert_resource(
             ShopifyCustomer,
             response.body["customers"],
             integration.id
           ) do
      maybe_enqueue_worker(shop, response.headers)
    end
  end

  defp maybe_enqueue_worker(shop, headers) do
    case NextLinkExtractor.call(headers) do
      nil ->
        :ok

      link ->
        %{shop: shop, link: link}
        |> new()
        |> Oban.insert()
    end
  end
end
