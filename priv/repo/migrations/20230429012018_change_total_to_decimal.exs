defmodule Moria.Repo.Migrations.ChangeTotalFieldToDecimal do
  use Ecto.Migration

  def up do
    execute """
     ALTER TABLE shopify_orders ALTER COLUMN total_price TYPE decimal USING total_price::numeric
    """
  end

  def down do
    execute """
     ALTER TABLE shopify_orders ALTER COLUMN total_price TYPE character varying(255)
    """
  end
end
