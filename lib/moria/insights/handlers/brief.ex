defmodule Moria.Insights.Handlers.Brief do
  @moduledoc """
  Handle the building of all things related to the Weekly brief
  """

  import Ecto.Query

  alias Moria.Insights.Brief
  alias Moria.Integrations.ShopifyCustomer
  alias Moria.Integrations.ShopifyOrder
  alias Moria.Integrations.ShopifyProduct
  alias Moria.Repo

  @doc """
  Returns the weekly brief containing the key insights for the week
  - Top 5 customers total spend
  - New products added
  - Most ordered products
  """
  @spec weekly_brief(User.t()) :: Brief.t()
  def weekly_brief(user) do
    with top_customers <- find_top_customers_total_spend(user),
         new_products <- find_new_products(user),
         high_interest_products <- find_high_interest_products(user),
         top_customer_report <- build_report(top_customers, new_products, high_interest_products) do
      {:ok, top_customer_report}
    end
  end

  defp build_report(top_customers, new_products, high_interest_products) do
    %Brief{}
    |> build_top_customers_total_spend(top_customers)
    |> build_new_products(new_products)
    |> build_high_interest_products(high_interest_products)
  end

  defp build_new_products(result, new_products) do
    Map.put(result, :new_products, new_products)
  end

  defp build_high_interest_products(result, %{max_quantity: 0}) do
    Map.put(result, :high_interest_products, %{quantity: 0, products: []})
  end

  defp build_high_interest_products(result, high_interest_products) do
    max_quantity = Map.get(high_interest_products, :max_quantity)
    product_orders = Map.delete(high_interest_products, :max_quantity)

    product_ids =
      product_orders
      |> Enum.filter(fn {_product_id, quantity} -> quantity == max_quantity end)
      |> Enum.map(fn {product_id, _} -> product_id end)

    products = Repo.all(from(sp in ShopifyProduct, where: sp.shopify_id in ^product_ids))

    Map.put(result, :high_interest_products, %{quantity: max_quantity, products: products})
  end

  defp build_top_customers_total_spend(result, top_customers) do
    acc = %{total_spent: 0, top_customers: []}

    report =
      top_customers
      |> Enum.reduce(acc, fn %{total_spent: total_spent} = per_customer_data, acc ->
        acc
        |> Map.update(:total_spent, 0, fn current -> Decimal.add(current, total_spent) end)
        |> Map.put(:top_customers, [per_customer_data | acc.top_customers])
      end)

    Map.put(result, :top_customers, report)
  end

  defp find_high_interest_products(user) do
    orders_last_week = get_last_week_orders(user)

    Enum.reduce(orders_last_week, %{max_quantity: 0}, fn order, acc ->
      if order.line_items do
        Enum.reduce(order.line_items, acc, fn line_item, acc ->
          product_id = line_item["product_id"]
          quantity = line_item["quantity"]
          acc = Map.update(acc, product_id, quantity, &(&1 + quantity))

          if Map.get(acc, product_id) > acc.max_quantity do
            Map.put(acc, :max_quantity, quantity)
          else
            acc
          end
        end)
      else
        acc
      end
    end)
  end

  defp get_last_week_orders(user) do
    %{start: start_of_week, end: end_of_week} = get_last_week_timings()

    query =
      from(orders in ShopifyOrder,
        join: integration in assoc(orders, :integration),
        where: integration.user_id == ^user.id,
        where: orders.processed_at <= ^end_of_week and orders.processed_at >= ^start_of_week
      )

    Repo.all(query)
  end

  defp find_new_products(user) do
    %{start: start_of_week, end: end_of_week} = get_last_week_timings()

    query =
      from(products in ShopifyProduct,
        join: integration in assoc(products, :integration),
        where: integration.user_id == ^user.id,
        where: products.published_at <= ^end_of_week and products.published_at >= ^start_of_week
      )

    Repo.all(query)
  end

  defp find_top_customers_total_spend(user) do
    %{start: start_of_week, end: end_of_week} = get_last_week_timings()

    query =
      from(customer in ShopifyCustomer,
        join: integration in assoc(customer, :integration),
        join: orders in assoc(customer, :shopify_orders),
        on: orders.shopify_customer_id == customer.shopify_id,
        where: integration.user_id == ^user.id,
        where: orders.processed_at <= ^end_of_week and orders.processed_at >= ^start_of_week,
        group_by: customer.id,
        order_by: [desc: fragment("sum(?)", type(orders.total_price, :decimal))],
        limit: 5,
        select: %{customer: customer, total_spent: sum(type(orders.total_price, :decimal))}
      )

    Repo.all(query)
  end

  defp get_last_week_timings() do
    this_time_last_week = Timex.shift(Timex.now(), weeks: -1)

    %{
      start: Timex.beginning_of_week(this_time_last_week),
      end: Timex.end_of_week(this_time_last_week)
    }
  end
end
