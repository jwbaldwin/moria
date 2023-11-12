defmodule Moria.Workers.SendWeeklyBriefEmailWorker do
  @moduledoc """
  Fetches the weekly brief for each shop and sends
  out the email (every Monday morning at 4:00AM EST/UTC)

  """
  use Oban.Worker, queue: :default, max_attempts: 3, tags: ["briefs"]

  alias Moria.Clients.Shopify
  alias Moria.Insights.Handlers.Brief

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"shop_url" => shop_url}}) do
    # build brief
    with shop <- Shopifex.Shops.get_shop_by_url(shop_url),
         client <- Shopify.client(shop),
         {:ok, owner} <- Shopify.shop_info(client),
         {:ok, brief} <- Brief.weekly_brief(shop),
         email <- MoriaWeb.Emails.BriefMailer.weekly_brief(owner, brief),
         {:ok, _} <- Moria.Mailer.deliver(email) do
      Logger.info("Weekly brief sent to shop #{shop_url} with email #{}")
    else
      error ->
        Logger.error("Weekly brief failed to send to shop #{shop_url} with error", error)
    end
  end
end
