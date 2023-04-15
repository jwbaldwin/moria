defmodule Moria.Repo.Migrations.CreateIntegrations do
  use Ecto.Migration

  def change do
    create table(:integrations) do
      add :type, :string
      add :shop, :string
      add :access_token, :string

      timestamps()
    end

    create unique_index(:integrations, [:shop])
  end
end
