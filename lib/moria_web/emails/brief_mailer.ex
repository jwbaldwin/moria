defmodule MoriaWeb.Emails.BriefMailer do
  use Phoenix.Swoosh, view: MoriaWeb.EmailView, layout: {MoriaWeb.EmailView, :root}

  def welcome(user, insights) do
    new()
    |> from("noreply@sample.test")
    |> to({user.name, user.email})
    |> subject("Your weekly brief - Kept")
    |> render_body("weekly_brief.html", user: user, insights: insights)
  end

  # `preview/0` function that builds your email using fixture data
  def preview() do
    insights =
      [
        "Your top 5 customers spent 1.2K last week",
        "3 new products were added to your shop",
        "Blue Jeans were your most popular product"
      ]
      |> Enum.with_index(fn insight, index -> {index + 1, insight} end)

    welcome(%{email: "user@sample.test", name: "Test User!"}, insights)
  end

  # `preview_details/0` with some useful metadata about your mailer
  def preview_details() do
    [
      title: "Weekly Brief",
      description: "The weekly insights digest sent on Monday"
    ]
  end
end
