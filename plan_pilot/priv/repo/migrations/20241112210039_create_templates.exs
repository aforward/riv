defmodule PlanPilot.Repo.Migrations.CreateTemplates do
  use Ecto.Migration

  def change do
    create table(:templates) do
      add :identifier, :string
      add :name, :string
      add :slug, :string
      add :text, :string
      add :placeholders, :jsonb

      timestamps()
    end

    create unique_index(:templates, [:identifier])
    create index(:templates, [:name])
    create index(:templates, [:slug])
  end
end
