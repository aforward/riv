defmodule PlanPilot.Repo.Migrations.AddTemplatesRecordState do
  use Ecto.Migration

  def change do
    alter table(:templates) do
      add :record_state, :string
    end

    create index(:templates, [:record_state])
    execute "UPDATE templates SET record_state = 'active';"
  end
end
