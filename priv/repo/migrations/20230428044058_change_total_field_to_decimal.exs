defmodule Moria.Repo.Migrations.ChangeTotalFieldToDecimal do
  use Ecto.Migration

  def up do
    execute """
     ALTER TABLE shopify_customers ALTER COLUMn total_spent TYPE decimal USING total_spent::numeric
    """
  end

  def down do
    execute """
     ALTER TABLE shopify_customers ALTER COLUMn total_spent TYPE character varying(255)
    """
  end

  # alter table(:shopify_customers) do
  # modify :total_spent, :decimal
  # end
end
