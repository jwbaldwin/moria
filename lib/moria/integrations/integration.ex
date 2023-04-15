defmodule Moria.Integrations.Integration do
  use Ecto.Schema
  import Ecto.Changeset

  schema "integrations" do
    field :type, Ecto.Enum, values: [:shopify]
    field :access_token, :string
    field :shop, :string

    timestamps()
  end

  @doc false
  def changeset(integration, attrs) do
    integration
    |> cast(attrs, [:type, :shop, :access_token])
    |> validate_required([:type, :shop, :access_token])
    |> unique_constraint(:shop)
  end
end
