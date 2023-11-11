defmodule Moria.Workers.SendWeeklyBriefEmailWorker do
  @moduledoc """
  Fetches the weekly brief for each shop and sends
  out the email (every Monday morning at 4:00AM EST/UTC)

  """
  use Oban.Worker, queue: :default, max_attempts: 3, tags: ["briefs"]

  alias Moria.Insights.Handlers.Brief

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"shop_url" => shop_url}}) do
    # build brief
    with shop <- Shopifex.Shops.get_shop_by_url(shop_url),
         {:ok, brief} <- Brief.weekly_brief(shop),
         email <- MoriaWeb.Emails.BriefMailer.weekly_brief(shop, brief),
         {:ok, _} <- Moria.Mailer.deliver(email) do
      Logger.info("Weekly brief sent to user #{user.email}")
    else
      error ->
        Logger.error("Weekly brief failed to send to user #{user_id} with error", error)
    end
  end
end
