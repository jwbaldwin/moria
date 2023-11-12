defmodule Moria.Repo.Migrations.CreateShopifyTables do
  use Ecto.Migration

  def change do
    create table(:shopify_shops) do
      add(:url, :string)
      add(:access_token, :string)
      add(:scope, :string)
      add(:last_synced, :utc_datetime)

      timestamps()
    end

    create(unique_index(:shopify_shops, [:url]))

    create table(:shopify_plans) do
      add(:name, :string)
      add(:price, :string)
      add(:features, {:array, :string})
      add(:grants, {:array, :string})
      add(:test, :boolean, default: false)
      add(:trial_days, :integer, default: 0)
      add(:usages, :integer)
      add(:type, :string)

      timestamps()
    end

    create(unique_index(:shopify_plans, [:name]))

    create table(:shopify_grants) do
      add(:charge_id, :bigint)
      add(:grants, {:array, :string})
      add(:remaining_usages, :integer)
      add(:total_usages, :integer, default: 0)
      add(:shop_id, references(:shopify_shops, on_delete: :nothing))

      timestamps()
    end

    create(index(:shopify_grants, [:grants], using: "GIN"))
  end
end
