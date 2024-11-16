defmodule PlanPilot.Repo.Migrations.AddTemplatesTags do
  use Ecto.Migration

  def change do
    alter table(:templates) do
      add :tags, :jsonb
    end

    execute "CREATE INDEX ON templates USING gin (tags)"
  end
end
