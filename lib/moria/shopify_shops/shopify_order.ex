defmodule Moria.ShopifyShops.ShopifyOrder do
  @moduledoc """
  Schema to capture imported orders

  https://shopify.dev/docs/api/admin-rest/2023-04/resources/order
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Moria.ShopifyShops.ShopifyCustomer

  @derive {Jason.Encoder,
           only: [
             :shopify_id,
             :shopify_created_at,
             :shopify_updated_at,
             :shopify_customer_id,
             :email,
             :line_items,
             :order_number,
             :processed_at,
             :total_price
           ]}

  schema "shopify_orders" do
    field(:shopify_id, :integer)
    field(:shopify_created_at, :utc_datetime)
    field(:shopify_updated_at, :utc_datetime)
    field(:email, :string)
    field(:line_items, {:array, :map})
    field(:name, :string)
    field(:number, :integer)
    field(:order_number, :integer)
    field(:processed_at, :utc_datetime)
    field(:source_url, :string)
    field(:total_price, :decimal)

    belongs_to(:shop, Moria.ShopifyShops.ShopifyShop, foreign_key: :shop_id)

    belongs_to(:shopify_customer, ShopifyCustomer,
      references: :shopify_id,
      foreign_key: :shopify_customer_id
    )

    timestamps()
  end

  @fields [
    :shopify_id,
    :shopify_created_at,
    :shopify_updated_at,
    :customer,
    :email,
    :line_items,
    :name,
    :number,
    :order_number,
    :processed_at,
    :source_url,
    :total_price,
    :shop_id,
    :shopify_customer_id
  ]

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, @fields)
    |> validate_required(:shopify_id)
  end
end
