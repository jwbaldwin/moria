defmodule Moria.Insights.Handlers.BriefTest do
  use Moria.DataCase, async: true

  alias Moria.Insights.Handlers.Brief

  test "calculates the top 5 customers spend in past week" do
    user = insert(:user)
    integration = insert(:integration, user: user)

    for total <- [100.00, 100.00, 50.00, 25.00, 25.00, 10.00, 10.00] do
      customer_and_order_fixture(integration, total)
    end

    {:ok, total_spent} = Brief.weekly_brief(user)
    IO.inspect(total_spent)
    assert total_spent == 300.00
  end

  defp customer_and_order_fixture(integration, total) do
    customer = insert(:shopify_customer, integration: integration)
    insert(:shopify_order, total_spent: total, shopify_customer: customer)
  end
end
