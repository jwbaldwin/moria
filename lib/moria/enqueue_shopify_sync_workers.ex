defmodule Moria.EnqueueShopifySyncWorkers do
  @moduledoc """
  Insert workers to sync:
   - Customers
   - Products -> enqueues -> Orders
   
   Also updates the `last_synced` timestamp for the Integration
  """

  alias Moria.Integrations
  alias Moria.Integrations.Integration
  alias Moria.Workers.ShopifyCustomersSyncWorker
  alias Moria.Workers.ShopifyProductsSyncWorker

  def call(%Integration{} = integration) do
    params = %{shop: integration.shop, since: integration.last_synced}

    Ecto.Multi.new()
    |> Oban.insert_all(:jobs, [
      ShopifyProductsSyncWorker.new(params),
      ShopifyCustomersSyncWorker.new(params)
    ])
    |> Ecto.Multi.update(
      :update_last_synced,
      Integrations.change_integration(integration, %{last_synced: Timex.now()})
    )
    |> Moria.Repo.transaction()
  end
end
