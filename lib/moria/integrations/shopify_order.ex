defmodule Moria.Integrations.ShopifyOrder do
  @moduledoc """
  Schema to capture imported orders

  https://shopify.dev/docs/api/admin-rest/2023-04/resources/order
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Moria.Integrations.Integration

  @derive {Jason.Encoder,
           only: [
             :shopify_id,
             :shopify_created_at,
             :shopify_updated_at,
             :email,
             :line_items,
             :customer,
             :order_number,
             :processed_at,
             :total_price
           ]}

  schema "shopify_orders" do
    field :shopify_id, :integer
    field :shopify_created_at, :utc_datetime
    field :shopify_updated_at, :utc_datetime
    field :customer, :map
    field :email, :string
    field :line_items, {:array, :map}
    field :name, :string
    field :number, :integer
    field :order_number, :integer
    field :processed_at, :utc_datetime
    field :source_url, :string
    field :total_price, :string

    belongs_to :integration, Integration

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
    :integration_id
  ]

  @doc false
  def changeset(integration, attrs) do
    integration
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
