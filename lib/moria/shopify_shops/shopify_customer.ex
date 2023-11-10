defmodule Moria.ShopifyShops.ShopifyCustomer do
  @moduledoc """
  Schema to capture imported customers

  https://shopify.dev/docs/api/admin-rest/2023-04/resources/customer
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Moria.ShopifyShops.ShopifyOrder

  @derive {Jason.Encoder,
           only: [
             :shopify_id,
             :shopify_created_at,
             :shopify_updated_at,
             :first_name,
             :last_name,
             :email,
             :email_marketing_consent,
             :verified_email,
             :phone,
             :sms_marketing_consent,
             :total_spent
           ]}
  schema "shopify_customers" do
    field(:shopify_id, :integer)
    field(:shopify_created_at, :utc_datetime)
    field(:shopify_updated_at, :utc_datetime)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:email_marketing_consent, :map)
    field(:verified_email, :boolean)
    field(:phone, :string)
    field(:sms_marketing_consent, :map)
    field(:total_spent, :decimal)

    belongs_to(:shop, Moria.ShopifyShops.ShopifyShop, foreign_key: :shop_id)

    has_many(:shopify_orders, ShopifyOrder,
      references: :shopify_id,
      foreign_key: :shopify_customer_id
    )

    timestamps()
  end

  @fields [
    :shopify_created_at,
    :email,
    :email_marketing_consent,
    :first_name,
    :shopify_id,
    :last_name,
    :phone,
    :sms_marketing_consent,
    :total_spent,
    :shopify_updated_at,
    :verified_email,
    :shop_id
  ]

  @doc false
  def changeset(customer, attrs) do
    customer
    |> cast(attrs, @fields)
    |> validate_required(:shopify_id)
  end
end
