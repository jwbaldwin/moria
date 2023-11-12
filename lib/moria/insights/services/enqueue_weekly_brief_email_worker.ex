defmodule Moria.Insights.Services.EnqueueWeeklyBriefEmailWorker do
  @moduledoc """
  Insert workers to send out the weekly brief email
  """
  use Oban.Worker, queue: :default, max_attempts: 3, tags: ["briefs"]
  import Ecto.Query

  alias Moria.Workers.SendWeeklyBriefEmailWorker
  alias Moria.Repo

  require Logger

  @impl Oban.Worker
  def perform(_) do
    shops = get_all_shops_to_email()

    Logger.info("Enqueuing the weekly brief email for #{length(shops)} shops")

    shops
    |> Enum.map(fn shop -> SendWeeklyBriefEmailWorker.new(%{shop_url: shop.url}) end)
    |> Oban.insert_all()

    :ok
  end

  defp get_all_shops_to_email() do
    from(shops in Moria.ShopifyShops.ShopifyShop)
    |> Repo.all()
  end
end
