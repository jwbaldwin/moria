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
    users = get_all_users_to_email()

    Logger.info("Enqueuing the weekly brief email for #{length(users)} users")

    users
    |> Enum.map(fn user -> SendWeeklyBriefEmailWorker.new(%{user_id: user.id}) end)
    |> Oban.insert_all()

    :ok
  end

  # TODO: when we add companies with multiple users, we'll send this to the "owner"
  defp get_all_users_to_email() do
    from(users in Moria.Users.User, join: integration in assoc(users, :integration))
    |> Repo.all()
  end
end
