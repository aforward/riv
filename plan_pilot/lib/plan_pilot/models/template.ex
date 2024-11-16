defmodule PlanPilot.Models.Template do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias PlanPilot.Models.Template
  alias PlanPilot.Repo
  alias Kore.Changesetter

  schema "templates" do
    field :identifier, :string
    field :record_state, :string
    field :name, :string
    field :slug, :string
    field :text, :string
    field :placeholders, {:array, :string}, default: []
    field :taglist, :string, virtual: true
    field :tags, {:array, :string}, default: []

    timestamps()
  end

  def changeset(record, params \\ :empty) do
    record
    |> cast(params, [
      :identifier,
      :record_state,
      :name,
      :slug,
      :text,
      :placeholders,
      :tags,
      :taglist
    ])
    |> Changesetter.token(:identifier, length: 20)
    |> Changesetter.defaulted(:record_state, "active")
    |> Changesetter.slug(:slug, field: :name, override: false)
    |> then(fn changeset ->
      case {Map.has_key?(changeset.changes, :taglist), get_field(changeset, :taglist, nil)} do
        {false, _} ->
          changeset

        {_, nil} ->
          changeset

        {_, list} ->
          list
          |> String.split(",")
          |> Enum.map(&String.trim/1)
          |> then(fn tags ->
            put_change(changeset, :tags, tags)
          end)
      end
    end)
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
      where: t.record_state != "deleted",
      order_by: [asc: t.name]
    )
    |> Repo.all()
  end

  def deleted() do
    from(
      t in Template,
      where: t.record_state == "deleted",
      order_by: [desc: t.updated_at]
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

  def mark_deleted(id), do: mark_as(id, "deleted")
  def mark_active(id), do: mark_as(id, "active")

  def mark_as(id, state) do
    case find(id) do
      nil -> :ok
      found -> update(found, %{record_state: state})
    end

    :ok
  end

  def fully_destroy(id) do
    case find(id) do
      nil ->
        {:error, :missing}

      found ->
        case found.record_state do
          "deleted" ->
            Repo.delete(found)
            {:ok, found}

          current_state ->
            {:error,
             "Must 'Template.mark_deleted' (deleted), current record_state is '#{current_state}'"}
        end
    end
  end
end
