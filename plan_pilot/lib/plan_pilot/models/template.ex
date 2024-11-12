defmodule PlanPilot.Models.Template do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias PlanPilot.Models.Template
  alias PlanPilot.Repo
  alias Kore.Changesetter

  schema "templates" do
    field :identifier, :string
    field :name, :string
    field :slug, :string
    field :text, :string
    field :placeholders, {:array, :string}, default: []

    timestamps()
  end

  def changeset(record, params \\ :empty) do
    record
    |> cast(params, [
      :identifier,
      :name,
      :slug,
      :text,
      :placeholders
    ])
    |> Changesetter.token(:identifier, length: 20)
    |> Changesetter.slug(:slug, field: :name, override: false)
    |> then(fn changeset ->
      case {Map.has_key?(changeset.changes, :placeholders),
            Map.has_key?(changeset.changes, :text), get_field(changeset, :text, nil)} do
        {true, _, _} ->
          # do not overwrite an existing value
          changeset

        {_, false, _} ->
          # do not overwrite if no text data
          changeset

        {_, _, text} ->
          put_change(changeset, :placeholders, Tmpl.Parser.extract_vars(text))
      end
    end)
  end

  def all() do
    from(
      t in Template,
      order_by: [asc: t.name]
    )
    |> Repo.all()
  end

  def find(nil), do: nil
  def find(""), do: nil

  def find(identifier) do
    Repo.one(from(t in Template, where: t.identifier == ^identifier))
  end

  def upsert(data) do
    case find(data["identifier"] || data[:identifier]) do
      nil ->
        add(data)

      found ->
        update(found, data)
    end
  end

  def add(data) do
    %Template{}
    |> changeset(data)
    |> Repo.insert()
  end

  def update(details, data) do
    details
    |> changeset(data)
    |> Repo.update()
  end
end
