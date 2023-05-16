defmodule MoriaWeb.InsightsView do
  use MoriaWeb, :view

  def render("weekly_brief.json", %{brief: brief}) do
    %{
      new_products: brief.new_products,
      top_customers: brief.top_customers,
      high_interest_products: brief.high_interest_products
    }
  end
end
