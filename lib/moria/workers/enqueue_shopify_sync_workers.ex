defmodule Moria.Workers.EnqueueShopifySyncWorkers do
  @moduledoc """
  Insert workers to sync:
   - Customers
   - Products -> enqueues -> Orders

   Then updates the `last_synced` timestamp for the integration
  """

  alias Moria.ShopifyShops.ShopifyShop
  alias Moria.Workers.ShopifyCustomersSyncWorker
  alias Moria.Workers.ShopifyProductsSyncWorker

  def call(%ShopifyShop{} = shop) do
    params = %{shop: shop.url, since: shop.last_synced}

    Ecto.Multi.new()
    |> Oban.insert_all(:jobs, [
      ShopifyProductsSyncWorker.new(params),
      ShopifyCustomersSyncWorker.new(params)
    ])
    |> Ecto.Multi.run(
      :update_last_synced,
      fn _, _ ->
        shop = Shopifex.Shops.update_shop(shop, %{last_synced: Timex.now()})
        {:ok, shop}
      end
    )
    |> Moria.Repo.transaction()
  end
end
