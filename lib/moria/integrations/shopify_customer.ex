defmodule Moria.Integrations.ShopifyCustomer do
  @moduledoc """
  Schema to capture imported customers

  https://shopify.dev/docs/api/admin-rest/2023-04/resources/customer
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Moria.Integrations.Integration

  schema "shopify_customers" do
    field :shopify_id, :integer
    field :shopify_created_at, :utc_datetime
    field :shopify_updated_at, :utc_datetime
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :email_marketing_consent, :map
    field :verified_email, :boolean
    field :phone, :string
    field :sms_marketing_consent, :map
    field :total_spent, :string

    belongs_to :integration, Integration

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
    :integration_id
  ]

  @doc false
  def changeset(integration, attrs) do
    integration
    |> cast(attrs, [@fields])
    |> validate_required([@fields])
  end
end