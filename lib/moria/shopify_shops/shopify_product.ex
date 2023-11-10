defmodule Moria.Integrations.ShopifyProduct do
  @moduledoc """
  Schema to capture imported products

  https://shopify.dev/docs/api/admin-rest/2023-04/resources/product
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Moria.Integrations.Integration

  @derive {Jason.Encoder,
           only: [
             :shopify_id,
             :shopify_created_at,
             :shopify_updated_at,
             :title,
             :status,
             :vendor,
             :product_type,
             :published_at,
             :handle
           ]}

  schema "shopify_products" do
    field :shopify_id, :integer
    field :shopify_created_at, :utc_datetime
    field :shopify_updated_at, :utc_datetime
    field :title, :string
    field :status, :string
    field :body_html, :string
    field :handle, :string
    field :options, {:array, :map}
    field :product_type, :string
    field :published_at, :utc_datetime
    field :vendor, :string

    belongs_to :integration, Integration
    timestamps()
  end

  @fields [
    :shopify_id,
    :title,
    :status,
    :body_html,
    :handle,
    :options,
    :product_type,
    :published_at,
    :shopify_created_at,
    :shopify_updated_at,
    :vendor,
    :integration_id
  ]

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, @fields)
    |> validate_required(:shopify_id)
  end
end
