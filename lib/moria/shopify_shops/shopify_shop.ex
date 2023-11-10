defmodule Moria.ShopifyShops.ShopifyShop do
  use Ecto.Schema
  import Ecto.Changeset
  
  schema "shopify_shops" do
    
    has_many :grants, Moria.ShopifyShops.ShopifyGrant, foreign_key: :shop_id
    
    timestamps()
  end

  @doc false
  def changeset(shopify_shop, attrs) do
    shopify_shop
    |> cast(attrs, [:url, :access_token, :scope])
    |> validate_required( [:url, :access_token, :scope])
  end
end
