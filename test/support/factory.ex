defmodule Moria.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: Moria.Repo

  alias Moria.Users.User
  alias Moria.Integrations.Integration
  alias Moria.Integrations.ShopifyCustomer
  alias Moria.Integrations.ShopifyOrder
  alias Moria.Integrations.ShopifyProduct

  def user_factory(attrs) do
    user = %User{
      name: sequence(:name, &"Hero #{&1}"),
      email: sequence(:email, &"email-#{&1}@remote.com"),
      password_hash: Pow.Ecto.Schema.Password.pbkdf2_hash(sequence(:name, &"Aa12345678912#{&1}"))
    }

    merge_attributes(user, attrs)
  end

  def integration_factory() do
    %Integration{
      type: :shopify,
      user: build(:user)
    }
  end

  def shopify_customer_factory(attrs) do
    first_name = sequence(:first_name, &"He-#{&1}")
    last_name = sequence(:last_name, &"Ro-#{&1}")

    customer = %ShopifyCustomer{
      first_name: first_name,
      last_name: last_name,
      email: "#{first_name}-#{last_name}@shopify.com",
      shopify_id: sequence(:shopify_id, & &1),
      integration: build(:integration)
    }

    merge_attributes(customer, attrs)
  end

  def shopify_order_factory(attrs) do
    shopify_customer = Map.get_lazy(attrs, :shopify_customer, fn -> build(:shopify_customer) end)

    %ShopifyOrder{
      email: "#{shopify_customer.email}",
      shopify_customer: shopify_customer,
      integration: build(:integration)
    }
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def shopify_product_factory(attrs) do
    product = %ShopifyProduct{
      title: sequence(:title, &"product-#{&1}"),
      shopify_id: sequence(:shopify_id, & &1),
      status: "active",
      integration: build(:integration)
    }

    merge_attributes(product, attrs)
  end
end
