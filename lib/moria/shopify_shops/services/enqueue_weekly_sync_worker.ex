defmodule Moria.Integrations.Services.EnqueueWeeklySyncWorker do
  @moduledoc """
  Insert workers to sync since last update
  """
  use Oban.Worker, queue: :default, max_attempts: 3, tags: ["sync"]
  import Ecto.Query

  alias Moria.EnqueueShopifySyncWorkers
  alias Moria.Repo

  require Logger

  @impl Oban.Worker
  def perform(_) do
    shops = get_all_shops_to_sync()

    Logger.info("Enqueuing the daily shop sync worker for #{length(shops)} shops")

    Enum.map(shops, fn shop -> EnqueueShopifySyncWorkers.call(shop) end)

    :ok
  end

  defp get_all_shops_to_sync() do
    from(shop in Moria.ShopifyShops.ShopifyShop)
    |> Repo.all()
  end
end
