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
    integrations = get_all_integrations_to_sync()

    Logger.info(
      "Enqueuing the daily integration sync worker for #{length(integrations)} Integrations"
    )

    # TODO: if I ever add integrations, need to sync them here
    integrations
    |> Enum.filter(&(&1.type == :shopify))
    |> Enum.map(fn integration -> EnqueueShopifySyncWorkers.call(integration) end)

    :ok
  end

  # TODO: when we add companies with multiple users, we'll send this to the "owner"
  defp get_all_integrations_to_sync() do
    from(integration in Moria.Integrations.Integration)
    |> Repo.all()
  end
end
