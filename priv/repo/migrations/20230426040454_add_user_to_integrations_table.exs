defmodule Moria.Repo.Migrations.AddUserToIntegrationsTable do
  use Ecto.Migration

  def change do
    alter table(:integrations) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create unique_index(:integrations, [:user_id])
  end
end
