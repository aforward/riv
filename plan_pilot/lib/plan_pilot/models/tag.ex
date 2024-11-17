defmodule PlanPilot.Models.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias PlanPilot.Models.Tag
  alias PlanPilot.Repo
  alias Kore.Changesetter

  schema "tags" do
    field :name, :string
    field :templatelist, :string, virtual: true
    field :templates, {:array, :string}, default: []

    timestamps()
  end

  def changeset(record, params \\ :empty) do
    record
    |> cast(params, [
      :name,
      :templates,
      :templatelist
    ])
    |> Changesetter.token(:name, length: 20)
    |> then(fn changeset ->
      case {Map.has_key?(changeset.changes, :templatelist),
            get_field(changeset, :templatelist, nil)} do
        {false, _} ->
          changeset

        {_, nil} ->
          changeset

        {_, list} ->
          list
          |> String.split(",")
          |> Enum.map(&String.trim/1)
          |> then(fn templates ->
            put_change(changeset, :templates, templates)
          end)
      end
    end)
  end

  def all() do
    from(
      t in Tag,
      order_by: [asc: t.name]
    )
    |> Repo.all()
  end

  def find(nil), do: nil
  def find(""), do: nil

  def find(name) do
    Repo.one(from(t in Tag, where: t.name == ^name))
  end

  def upsert(data) do
    case find(data["name"] || data[:name]) do
      nil ->
        add(data)

      found ->
        update(found, data)
    end
  end

  def add(data) do
    %Tag{}
    |> changeset(data)
    |> Repo.insert()
  end

  def update(details, data) do
    details
    |> changeset(data)
    |> Repo.update()
  end
end
