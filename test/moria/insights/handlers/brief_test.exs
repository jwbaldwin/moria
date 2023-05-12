defmodule Moria.Insights.Handlers.BriefTest do
  use Moria.DataCase, async: true

  alias Moria.Insights.Handlers.Brief

  test "has sane defaults when there is no activity in the past week" do
    user = insert(:user)
    insert(:integration, user: user)

    {:ok,
     %Moria.Insights.Brief{
       new_products: [],
       top_customers: %{total_spent: 0, top_customers: []},
       high_interest_products: %{quantity: 0, products: []}
     }} = Brief.weekly_brief(user)
  end

  test "finds the new products published the previous week" do
    user = insert(:user)
    integration = insert(:integration, user: user)
    last_week = Timex.shift(Timex.now(), weeks: -1)

    insert(:shopify_product, integration: integration, published_at: last_week)

    {:ok, %{new_products: new_products}} = Brief.weekly_brief(user)
    assert length(new_products) == 1
  end

  test "calculates the top 5 customers spend in previous week" do
    user = insert(:user)
    integration = insert(:integration, user: user)

    for total <- [1.00, 10.00, 10.00, 50.00, 50.00] do
      customer_and_order_fixture(integration, total)
    end

    high_value_customer(integration)

    {:ok, %{top_customers: top_customers}} = Brief.weekly_brief(user)
    assert top_customers.total_spent == Decimal.new("320.0")
  end

  test "calculates the top 5 customers spend in previous week for a single order" do
    user = insert(:user)
    integration = insert(:integration, user: user)

    for total <- [1.00] do
      customer_and_order_fixture(integration, total)
    end

    high_value_customer(integration)

    {:ok, %{top_customers: top_customers}} = Brief.weekly_brief(user)
    assert top_customers.total_spent == Decimal.new("201.0")
  end

  test "finds the products that were ordered the most in previous week" do
    user = insert(:user)
    integration = insert(:integration, user: user)
    last_week = Timex.shift(Timex.now(), weeks: -1)

    product_one = insert(:shopify_product, integration: integration)
    product_two = insert(:shopify_product, integration: integration)

    insert(:shopify_order,
      integration: integration,
      line_items: line_items(product_one, product_two),
      processed_at: last_week
    )

    {:ok, %{high_interest_products: high_interest_products}} = Brief.weekly_brief(user)

    assert high_interest_products.quantity == 1
    assert length(high_interest_products.products) == 2
  end

  defp customer_and_order_fixture(integration, total) do
    customer = insert(:shopify_customer, integration: integration)

    last_week = Timex.shift(Timex.now(), weeks: -1)

    insert(:shopify_order,
      total_price: total,
      integration: integration,
      shopify_customer: customer,
      processed_at: last_week
    )
  end

  defp high_value_customer(integration) do
    customer = insert(:shopify_customer, integration: integration)

    last_week = Timex.shift(Timex.now(), weeks: -1)

    insert(:shopify_order,
      total_price: 100.00,
      integration: integration,
      shopify_customer: customer,
      processed_at: last_week
    )

    insert(:shopify_order,
      total_price: 100.00,
      integration: integration,
      shopify_customer: customer,
      processed_at: last_week
    )
  end

  defp line_items(product_one, product_two) do
    [
      %{
        "id" => 13_922_643_378_450,
        "name" => "The Complete Snowboard - Sunset",
        "price" => "699.95",
        "price_set" => %{
          "presentment_money" => %{"amount" => "699.95", "currency_code" => "USD"},
          "shop_money" => %{"amount" => "699.95", "currency_code" => "USD"}
        },
        "product_exists" => true,
        "product_id" => product_one.shopify_id,
        "properties" => [],
        "quantity" => 1,
        "title" => "The Complete Snowboard",
        "variant_id" => 44_836_228_530_450,
        "variant_inventory_management" => "shopify",
        "variant_title" => "Sunset",
        "vendor" => "Snowboard Vendor"
      },
      %{
        "id" => 13_922_643_411_218,
        "name" => "The 3p Fulfilled Snowboard",
        "price" => "2629.95",
        "price_set" => %{
          "presentment_money" => %{"amount" => "2629.95", "currency_code" => "USD"},
          "shop_money" => %{"amount" => "2629.95", "currency_code" => "USD"}
        },
        "product_exists" => true,
        "product_id" => product_two.shopify_id,
        "properties" => [],
        "quantity" => 1,
        "title" => "The 3p Fulfilled Snowboard",
        "variant_id" => 44_836_228_628_754,
        "variant_inventory_management" => "shopify",
        "variant_title" => nil,
        "vendor" => "Kept Good Company"
      }
    ]
  end
end
