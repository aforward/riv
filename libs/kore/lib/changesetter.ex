defmodule Kore.Changesetter do
  import Ecto.Changeset
  alias Kore.{Token, Slugger}

  @doc """
  Changesets can run without a "changeset", by passing a tuple
  containing both the data and the supported types as a tuple instead of a struct:

  A convenience function to generate a changeset without a struct like `%User{}`.

      Changesetter.create(
        %{"first_name" => "Andrew"},
        %{first_name: :string, last_name: :string, email: :string})

  If you want to seed the underlying mode, then use the &create/3 function

      Changesetter.create(
        %{"first_name" => "Normal Andrew"},
        %{"first_name" => "Super Andrew"},
        %{first_name: :string, last_name: :string, email: :string})
  """
  def create(params, types), do: create(%{}, params, types)

  def create(record, params, types) do
    Ecto.Changeset.cast({record, types}, params, Map.keys(types))
  end

  @doc """
  Check for the `field` in the provided changeset, and if
  not found then set it ot the it based on the provide function.

  ## Examples

      iex> Kore.Changesetter.create(%{}, %{apples: :string})
      ...> |> Kore.Changesetter.defaulted(:apples, "blue")
      ...> |> Map.get(:changes)
      %{apples: "blue"}

      iex> Kore.Changesetter.create(%{apples: "red"}, %{}, %{apples: :string})
      ...> |> Kore.Changesetter.defaulted(:apples, "blue")
      ...> |> Map.get(:changes)
      %{}

      iex> Kore.Changesetter.create(%{"apples" => "red"}, %{apples: :string})
      ...> |> Kore.Changesetter.defaulted(:apples, "blue")
      ...> |> Map.get(:changes)
      %{apples: "red"}
  """
  def defaulted(changeset, field, default_if_missing) do
    case get_field(changeset, field, nil) do
      nil -> put_change_if(changeset, field, default_if_missing)
      _ -> changeset
    end
  end

  @doc """
  Check for the `field` (typically :identifier) in the provided changeset,
  and if not found, the generate a new one based on `Kore.Token`.

      Changesetter.token(changeset, :identifier, length: 20)
  """
  def token(changeset, field, token_opts \\ [length: 20]) do
    case get_field(changeset, field, nil) do
      nil -> put_change_if(changeset, field, Token.generate(token_opts))
      _ -> changeset
    end
  end

  @doc """
  Normalize the identifier to be based on the `reference_type` and
  `reference_id`, and if not then fallback and generate a token
  """
  def reference_identifier(changeset, opts \\ [length: 20]) do
    identifier = get_field(changeset, :identifier, nil)
    reference_type = get_field(changeset, :reference_type, nil)
    reference_id = get_field(changeset, :reference_id, nil)

    suffix =
      case Keyword.get(opts, :suffix) do
        nil -> nil
        field -> get_field(changeset, field, nil)
      end

    cond do
      !is_nil(identifier) ->
        changeset

      !is_nil(reference_type) && !is_nil(reference_id) ->
        identifier =
          [reference_type, reference_id, suffix]
          |> Enum.reject(&is_nil/1)
          |> Enum.join(":::")

        changeset
        |> put_change(:identifier, identifier)

      :else ->
        token(changeset, :identifier, opts)
    end
  end

  @doc """
  Slugify the lookup field based on `Kore.Slugger`.

      Changesetter.slug(changeset, :slug, field: :name, override: true)
  """
  def slug(changeset, field, opts \\ []) do
    override = Keyword.get(opts, :override)
    lookup_field = Keyword.get(opts, :field)
    lookup_value = get_field(changeset, lookup_field, nil)
    existing_value = get_field(changeset, field, nil)

    cond do
      is_nil(lookup_value) ->
        changeset

      !override && !is_nil(existing_value) ->
        changeset

      :else ->
        put_change(changeset, field, Slugger.slugify(lookup_value))
    end
  end

  def put_id_change(%{changes: changes, data: data} = changeset, field_prefix, findfn) do
    name_field = String.to_existing_atom("#{field_prefix}_name")
    id_field = String.to_existing_atom("#{field_prefix}_id")

    should_update =
      cond do
        !is_nil(changes[name_field]) ->
          is_nil(changes[id_field])

        !is_nil(Map.get(data, name_field)) ->
          is_nil(changes[id_field]) && is_nil(Map.get(data, id_field))

        :else ->
          false
      end

    if should_update do
      (changes[name_field] || Map.get(data, name_field))
      |> findfn.()
      |> case do
        nil ->
          changeset

        obj ->
          changeset
          |> put_change(id_field, obj.identifier)
          |> put_change(name_field, obj.name)
      end
    else
      changeset
    end
  end

  def merge_map(changes, record, field_id) do
    case Map.get(changes, "#{field_id}") do
      nil ->
        changes

      updates ->
        (Map.get(record, field_id) || %{})
        |> Map.merge(updates)
        |> then(&Map.put(changes, "#{field_id}", &1))
    end
  end

  def merge_unset(changes, record, field_id) do
    case Map.get(changes, "#{field_id}") do
      nil ->
        changes

      updates ->
        existing =
          (Map.get(record, field_id) || %{})
          |> Enum.reject(fn {_k, v} -> is_nil(v) end)
          |> Enum.into(%{})

        updates
        |> Map.merge(existing)
        |> then(&Map.put(changes, "#{field_id}", &1))
    end
  end

  defp put_change_if(changeset, to_field, val) do
    if get_field(changeset, to_field, nil) == val do
      changeset
    else
      put_change(changeset, to_field, val)
    end
  end
end
