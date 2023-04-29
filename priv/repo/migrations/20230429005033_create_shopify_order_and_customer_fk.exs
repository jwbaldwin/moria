defmodule Moria.Repo.Migrations.CreateShopifyOrderAndCustomerFk do
  use Ecto.Migration

  def change do
    alter table(:shopify_orders) do
      remove :customer

      add :shopify_customer_id, references(:shopify_customers, on_delete: :delete_all), null: true
    end
  end
end
