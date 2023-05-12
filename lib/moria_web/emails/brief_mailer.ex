defmodule MoriaWeb.Emails.BriefMailer do
  use Phoenix.Swoosh, view: MoriaWeb.EmailView, layout: {MoriaWeb.EmailView, :root}

  alias Moria.Users.User
  alias Moria.Insights.Brief

  @spec weekly_brief(User.t(), Brief.t()) :: :ok
  def weekly_brief(user, brief) do
    new()
    |> from("noreply@sample.test")
    |> to({user.name, user.email})
    |> subject("Your weekly brief - Kept")
    |> render_body("weekly_brief.html",
      insights: build_insights_sentences_from_brief(brief),
      brief_url: build_brief_url()
    )
  end

  # `preview/0` function that builds your email using fixture data
  def preview() do
    brief = %Brief{
      top_customers: %{
        total_spent: 479.00,
        customers: []
      },
      new_products: 3,
      high_interest_products: %{
        quantity: 3,
        products: [%{title: "Blue Jeans - Washed"}]
      }
    }

    weekly_brief(%{email: "user@sample.test", name: "Tim Cook"}, brief)
  end

  defp build_insights_sentences_from_brief(brief) do
    [
      "Your top 5 customers spent #{brief.top_customers.total_spent} last week",
      "#{brief.new_products} new products were added to your shop",
      build_high_interest_products_sentence(brief.high_interest_products.products)
    ]
    |> Enum.with_index(fn sentence, index -> {index + 1, sentence} end)
  end

  defp build_high_interest_products_sentence([]), do: "No products received high interest"

  defp build_high_interest_products_sentence([product]),
    do: "#{product.title} was your most popular product"

  defp build_high_interest_products_sentence([first, second]),
    do: "#{first.title} and #{second.title} were your most popular products"

  defp build_high_interest_products_sentence(products) do
    [start, last] =
      products
      |> Enum.map(& &1.title)
      |> Enum.split(length(products) - 1)

    Enum.join(start, ", ") <> "and #{last} were your most popular products"
  end

  defp build_brief_url() do
    "https://app.gokept.com"
  end

  # `preview_details/0` with some useful metadata about your mailer
  def preview_details() do
    [
      title: "Weekly Brief",
      description: "The weekly insights digest sent on Monday"
    ]
  end
end
