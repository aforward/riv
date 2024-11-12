defmodule PlanPilot.Models.Action do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias Kore.Pretty
  alias PlanPilot.Repo
  alias PlanPilot.Models.Action

  schema "actions" do
    field :name, :string
    field :summary, :string
    field :entity_type, :string
    field :entity_id, :string
    field :data, :map

    timestamps()
  end

  def changeset(record, params \\ :empty) do
    record
    |> cast(params, [:name, :entity_type, :entity_id, :summary, :data])
    |> validate_required([:name, :entity_type, :entity_id])
  end

  def add(name, type, id, data \\ %{}) do
    %Action{}
    |> Action.changeset(%{
      name: name,
      entity_type: type,
      entity_id: id,
      summary: data["summary"],
      data: Pretty.jsonable(data)
    })
    |> Repo.insert!()
  end

  def summary(type, id) do
    from(t in Action,
      where: t.entity_type == ^type and t.entity_id == ^id,
      select: [t.name, t.summary]
    )
    |> Repo.all()
    |> Enum.map(fn
      [name, nil] -> name
      [name, summary] -> "#{name} (#{summary})"
    end)
  end

  def details(type, id) do
    from(t in Action,
      where: t.entity_type == ^type and t.entity_id == ^id,
      select: [t.name, t.data]
    )
    |> Repo.all()
    |> Enum.map(fn [name, data] -> {name, data} end)
  end
end
