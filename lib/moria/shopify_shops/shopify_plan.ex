defmodule Moria.ShopifyShops.ShopifyPlan do
  use Ecto.Schema
  import Ecto.Changeset

  schema "shopify_plans" do
    field :test, :boolean, default: false
    field :trial_days, :integer, default: 0

    timestamps()
  end

  @doc false
  def changeset(shopify_plan, attrs) do
    shopify_plan
    |> cast(attrs, [:name, :price, :features, :grants, :test, :trial_days, :usages, :type])
    |> validate_required([:name, :price, :features, :grants, :test, :trial_days, :usages, :type])
  end
end
