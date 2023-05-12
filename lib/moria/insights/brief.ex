defmodule Moria.Insights.Brief do
  @type t :: %Moria.Insights.Brief{
          new_products: list(),
          top_customers: top_customers(),
          high_interest_products: high_interest_products()
        }

  defstruct [
    :new_products,
    :top_customers,
    :high_interest_products
  ]

  @type customer :: any()
  @type product :: any()

  @type top_customers :: %{
          total_spent: Decimal.t(),
          customers: [customer()]
        }

  @type high_interest_products :: %{
          quantity: non_neg_integer(),
          products: [product()]
        }
end
