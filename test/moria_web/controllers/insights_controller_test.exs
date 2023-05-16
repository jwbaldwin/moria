defmodule MoriaWeb.InsightsControllerTest do
  use MoriaWeb.ConnCase, async: true

  setup %{conn: conn} do
    user = insert(:user)
    conn = Pow.Plug.assign_current_user(conn, user, [])

    {:ok, conn: conn}
  end

  test "returns a brief", %{conn: conn} do
    response = conn |> get(~p"/api/insights/weekly-brief") |> json_response(200)

    assert %{
             "high_interest_products" => %{"products" => [], "quantity" => 0},
             "new_products" => [],
             "top_customers" => %{"top_customers" => [], "total_spent" => 0}
           } == response
  end
end
