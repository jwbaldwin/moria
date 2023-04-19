defmodule Moria.Repo.Migrations.AddShopifyProductsOrdersCustomers do
  use Ecto.Migration

  def change do
    create table(:shopify_products) do
      add :shopify_id, :bigint
      add :shopify_created_at, :utc_datetime
      add :shopify_updated_at, :utc_datetime
      add :title, :string
      add :status, :string
      add :body_html, :string
      add :handle, :string
      add :options, {:array, :map}
      add :product_type, :string
      add :published_at, :utc_datetime
      add :vendor, :string

      add :integration_id, references(:integrations, on_delete: :delete_all), null: false

      timestamps()
    end

    create table(:shopify_orders) do
      add :shopify_id, :bigint
      add :shopify_created_at, :utc_datetime
      add :shopify_updated_at, :utc_datetime
      add :customer, :map
      add :email, :string
      add :line_items, {:array, :map}
      add :name, :string
      add :number, :integer
      add :order_number, :integer
      add :processed_at, :utc_datetime
      add :source_url, :string
      add :total_price, :string

      add :integration_id, references(:integrations, on_delete: :delete_all), null: false

      timestamps()
    end

    create table(:shopify_customers) do
      add :shopify_id, :bigint
      add :shopify_created_at, :utc_datetime
      add :shopify_updated_at, :utc_datetime
      add :first_name, :string
      add :last_name, :string
      add :email, :string
      add :email_marketing_consent, :map
      add :verified_email, :boolean
      add :phone, :string
      add :sms_marketing_consent, :map
      add :total_spent, :string

      add :integration_id, references(:integrations, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:shopify_customers, [:shopify_id])
    create unique_index(:shopify_orders, [:shopify_id])
    create unique_index(:shopify_products, [:shopify_id])
  end
end
