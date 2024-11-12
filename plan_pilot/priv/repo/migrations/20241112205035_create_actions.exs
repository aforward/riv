defmodule PlanPilot.Repo.Migrations.CreateActions do
  use Ecto.Migration

  def change do
    create table(:actions) do
      add :name, :string
      add :summary, :string
      add :entity_type, :string
      add :entity_id, :string
      add :data, :jsonb

      timestamps()
    end

    create index(:actions, [:name])
    create index(:actions, [:entity_type, :entity_id])
  end
end
