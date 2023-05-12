defmodule Moria.EnqueueShopifySyncWorkers do
  @moduledoc """
  Insert workers to sync:
   - Customers
   - Products -> enqueues -> Orders
  """

  alias Moria.Integrations.Integration
  alias Moria.Workers.ShopifyCustomersSyncWorker
  alias Moria.Workers.ShopifyProductsSyncWorker

  def call(%Integration{} = integration) do
    params = %{shop: integration.shop}

    [
      ShopifyProductsSyncWorker.new(params),
      ShopifyCustomersSyncWorker.new(params)
    ]
    |> Oban.insert_all()
  end
end
