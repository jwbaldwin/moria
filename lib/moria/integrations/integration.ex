defmodule Moria.Integrations.Integration do
  use Ecto.Schema
  import Ecto.Changeset

  alias Moria.Users.User
  alias Moria.Integrations.ShopifyProduct
  alias Moria.Integrations.ShopifyOrder
  alias Moria.Integrations.ShopifyCustomer

  @derive {Jason.Encoder, only: [:id, :type, :shop]}
  schema "integrations" do
    field :type, Ecto.Enum, values: [:shopify]
    field :access_token, :string
    field :shop, :string
    field :last_synced, :utc_datetime

    belongs_to :user, User

    has_many :products, ShopifyProduct
    has_many :orders, ShopifyOrder
    has_many :customers, ShopifyCustomer

    timestamps()
  end

  @required_fields [:type, :shop, :access_token, :user_id]
  @fields [:last_synced | @required_fields]

  @doc false
  def changeset(integration, attrs) do
    integration
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:shop)
  end
end
