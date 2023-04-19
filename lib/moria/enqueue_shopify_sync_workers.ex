defmodule Moria.EnqueueShopifySyncWorkers do
  @moduledoc """
  Insert workers to sync:
   - Orders
   - Customers
   - Products
  """

  alias Moria.Integrations.Integration
  alias Moria.Workers.ShopifyOrdersSyncWorker
  alias Moria.Workers.ShopifyCustomersSyncWorker
  alias Moria.Workers.ShopifyProductsSyncWorker

  def call(%Integration{} = integration) do
    params = %{shop: integration.shop}

    [
      ShopifyOrdersSyncWorker.new(params),
      ShopifyProductsSyncWorker.new(params),
      ShopifyCustomersSyncWorker.new(params)
    ]
    |> Oban.insert_all()
  end
end
