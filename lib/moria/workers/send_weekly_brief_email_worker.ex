defmodule Moria.Workers.SendWeeklyBriefEmailWorker do
  @moduledoc """
  Fetches the weekly brief for each User (and their integration) and sends
  out the email (every Monday morning at 4:00AM EST/UTC)

  """
  use Oban.Worker, queue: :default, max_attempts: 3, tags: ["briefs"]

  alias Moria.Users
  alias Moria.Insights.Handlers.Brief

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"user_id" => user_id}}) do
    # build brief
    with {:ok, user} <- Users.fetch_user(user_id),
         {:ok, brief} <- Brief.weekly_brief(user),
         email <- MoriaWeb.Emails.BriefMailer.weekly_brief(user, brief),
         {:ok, _} <- Moria.Mailer.deliver(email) do
      Logger.info("Weekly brief sent to user #{user.email}")
    else
      error ->
        Logger.error("Weekly brief failed to send to user #{user_id} with error", error)
    end
  end
end
