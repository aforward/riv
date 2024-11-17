defmodule PlanPilot.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :name, :string
      add :templates, :jsonb

      timestamps()
    end

    create unique_index(:tags, [:name])
    execute "CREATE INDEX ON tags USING gin (templates)"
  end
end
