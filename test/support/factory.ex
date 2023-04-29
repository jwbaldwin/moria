defmodule Moria.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: Moria.Repo

  alias Moria.Users.User
  alias Moria.Integrations.ShopifyCustomer
  alias Moria.Integrations.ShopifyOrder
  alias Moria.Integrations.ShopifyProduct

  def user_factory() do
    %User{
      name: "Jane Smith",
      email: sequence(:email, &"email-#{&1}@example.com")
    }
  end
end
