defmodule Moria.Insights.Handlers.Brief do
  @moduledoc """
  Handle the building of all things related to the Weekly brief
  """

  import Ecto.Query

  alias Moria.Integrations.Integration
  alias Moria.Integrations.ShopifyCustomer
  alias Moria.Integrations.ShopifyOrder
  alias Moria.Integrations.ShopifyProduct
  alias Moria.Repo

  @doc """
  Returns the weekly brief containing the key insights for the week
  - Top 5 customers total spend
  - Quickly selling products
  - New products added
  - Products getting interest
  """
  def weekly_brief(user) do
    with top_customers <- find_top_customers_total_spend(user) do
      {:ok, top_customers}
    end
  end

  # All orders last week
  # sum of how much spent by customer
  # get top 5
  defp find_top_customers_total_spend(user) do
    this_time_last_week = Timex.shift(Timex.now(), weeks: -1)
    start_of_week = Timex.beginning_of_week(this_time_last_week)
    end_of_week = Timex.end_of_week(this_time_last_week)

    query =
      from(orders in ShopifyOrder,
        join: integration in assoc(orders, :integration),
        where: integration.user_id == ^user.id,
        where: orders.processed_at <= ^end_of_week and orders.processed_at >= ^start_of_week,
        group_by: orders.shopify_customer_id,
        limit: 5
      )

    Repo.aggregate(query, :sum, :total_spent)
  end
end
