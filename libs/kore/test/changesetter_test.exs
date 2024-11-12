defmodule Kore.ChangesetterTest do
  use ExUnit.Case, async: false
  alias Kore.Changesetter
  doctest Changesetter

  defmodule MyRecord do
    use Ecto.Schema

    schema "my_records" do
      field(:myfield, :string)
      field(:client_name, :string)
      field(:client_id, :string)
      field(:stuff, :map)
    end
  end

  def find_by(name) do
    case name do
      "unknown" -> nil
      _else -> %{identifier: "#{name}_abc123", name: "#{name}_name"}
    end
  end

  def reference_changeset(model \\ %{}) do
    Changesetter.create(model, %{
      identifier: :string,
      slug: :string,
      reference_type: :string,
      reference_id: :string
    })
  end

  describe "put_id_change/3" do
    test "field not part of changes" do
      changeset = %Ecto.Changeset{changes: %{}, data: %MyRecord{}}
      assert changeset == Changesetter.put_id_change(changeset, :client, &find_by/1)
    end

    test "name and id part of changes" do
      changeset = %Ecto.Changeset{changes: %{client_name: "x", client_id: "y"}, data: %MyRecord{}}
      assert changeset == Changesetter.put_id_change(changeset, :client, &find_by/1)
    end

    test "name not found" do
      changeset = %{changes: %{client_name: "unknown"}, data: %MyRecord{}}
      assert changeset == Changesetter.put_id_change(changeset, :client, &find_by/1)
    end

    test "name found in changes" do
      changeset =
        %MyRecord{myfield: "me", client_id: "old"}
        |> Ecto.Changeset.cast(%{client_name: "hello"}, [:client_name, :client_id])

      expected =
        %MyRecord{myfield: "me", client_id: "old"}
        |> Ecto.Changeset.cast(%{client_name: "hello_name", client_id: "hello_abc123"}, [
          :client_name,
          :client_id
        ])
        |> Map.put(:params, %{"client_name" => "hello"})

      assert expected == Changesetter.put_id_change(changeset, :client, &find_by/1)
    end

    test "name and id in record, ignore" do
      changeset =
        %MyRecord{myfield: "me", client_name: "x1", client_id: "x2"}
        |> Ecto.Changeset.cast(%{}, [:client_name, :client_id])

      assert changeset == Changesetter.put_id_change(changeset, :client, &find_by/1)
    end

    test "name in record, but id NOT set" do
      changeset =
        %MyRecord{myfield: "me", client_name: "goodbye"}
        |> Ecto.Changeset.cast(%{}, [:client_name, :client_id])

      expected =
        %MyRecord{myfield: "me", client_name: "goodbye"}
        |> Ecto.Changeset.cast(%{client_name: "goodbye_name", client_id: "goodbye_abc123"}, [
          :client_name,
          :client_id
        ])
        |> Map.put(:params, %{})

      assert expected == Changesetter.put_id_change(changeset, :client, &find_by/1)
    end
  end

  describe "merge_map" do
    test "not set" do
      changes = %{"a" => 1}
      assert changes == Changesetter.merge_map(changes, %MyRecord{}, :stuff)
    end

    test "no existing values set" do
      changes = %{"stuff" => %{"a" => 1}}
      assert changes == Changesetter.merge_map(changes, %MyRecord{}, :stuff)
    end

    test "merge existing values (changes win)" do
      changes = %{"stuff" => %{"a" => 1}}
      record = %MyRecord{stuff: %{"a" => "old", "b" => "keep"}}
      expected = %{"stuff" => %{"a" => 1, "b" => "keep"}}
      assert expected == Changesetter.merge_map(changes, record, :stuff)
    end

    test "if atom, overwrite all" do
      changes = %{stuff: %{"a" => 1}}
      record = %MyRecord{stuff: %{"a" => "old", "b" => "keep"}}
      assert changes == Changesetter.merge_map(changes, record, :stuff)
    end
  end

  describe "merge_unset" do
    test "not set" do
      changes = %{"a" => 1}
      assert changes == Changesetter.merge_unset(changes, %MyRecord{}, :stuff)
    end

    test "no existing values set" do
      changes = %{"stuff" => %{"a" => 1}}
      assert changes == Changesetter.merge_unset(changes, %MyRecord{}, :stuff)
    end

    test "merge existing values (existing win if not nil)" do
      changes = %{"stuff" => %{"a" => 1}}
      record = %MyRecord{stuff: %{"a" => "old", "b" => "keep"}}
      expected = %{"stuff" => %{"a" => "old", "b" => "keep"}}
      assert expected == Changesetter.merge_unset(changes, record, :stuff)
    end

    test "merge existing values (new wins if not nil)" do
      changes = %{"stuff" => %{"a" => 1}}
      record = %MyRecord{stuff: %{"a" => nil, "b" => "keep"}}
      expected = %{"stuff" => %{"a" => 1, "b" => "keep"}}
      assert expected == Changesetter.merge_unset(changes, record, :stuff)
    end

    test "if atom, overwrite all" do
      changes = %{stuff: %{"a" => 1}}
      record = %MyRecord{stuff: %{"a" => "old", "b" => "keep"}}
      assert changes == Changesetter.merge_unset(changes, record, :stuff)
    end
  end

  describe "token" do
    test "set the value defaulted to size 20" do
      assert Changesetter.create(%{}, %{passcode: :string})
             |> Changesetter.token(:passcode)
             |> Map.get(:changes)
             |> Map.get(:passcode)
             |> String.length() == 20
    end

    test "set the value override length" do
      assert Changesetter.create(%{}, %{passcode: :string})
             |> Changesetter.token(:passcode, length: 7)
             |> Map.get(:changes)
             |> Map.get(:passcode)
             |> String.length() == 7
    end

    test "do not override an existing value" do
      assert Changesetter.create(%{"identifier" => "x123"}, %{identifier: :string})
             |> Changesetter.token(:identifier)
             |> Map.get(:changes)
             |> Map.get(:identifier) ==
               "x123"
    end
  end

  describe "reference_identifier" do
    test "no reference then auto gen using token" do
      assert reference_changeset()
             |> Changesetter.reference_identifier()
             |> Map.get(:changes)
             |> Map.get(:identifier)
             |> String.length() == 20
    end

    test "set the length of the default size" do
      assert reference_changeset()
             |> Changesetter.reference_identifier(length: 7)
             |> Map.get(:changes)
             |> Map.get(:identifier)
             |> String.length() == 7
    end

    test "do not override an existing value" do
      assert reference_changeset(%{"identifier" => "x123"})
             |> Changesetter.reference_identifier()
             |> Map.get(:changes)
             |> Map.get(:identifier) ==
               "x123"
    end

    test "lookup reference_type and reference_id" do
      assert reference_changeset(%{"reference_type" => "goop", "reference_id" => "abc123"})
             |> Changesetter.reference_identifier()
             |> Map.get(:changes)
             |> Map.get(:identifier) ==
               "goop:::abc123"
    end

    test "allow a suffix" do
      assert reference_changeset(%{
               "reference_type" => "goop",
               "reference_id" => "abc123",
               "slug" => "my-team"
             })
             |> Changesetter.reference_identifier(suffix: :slug)
             |> Map.get(:changes)
             |> Map.get(:identifier) ==
               "goop:::abc123:::my-team"
    end
  end

  describe "slug" do
    test "handle nil" do
      assert Changesetter.create(%{}, %{name: :string, slug: :string})
             |> Changesetter.slug(:slug, field: :name)
             |> Map.get(:changes)
             |> Map.get(:slug) == nil
    end

    test "slugify the existing value" do
      assert Changesetter.create(%{name: "A Name"}, %{name: :string, slug: :string})
             |> Changesetter.slug(:slug, field: :name)
             |> Map.get(:changes)
             |> Map.get(:slug) == "a-name"
    end

    test "do not override an existing value" do
      assert Changesetter.create(%{"name" => "A Name", "slug" => "my-slug"}, %{
               name: :string,
               slug: :string
             })
             |> Changesetter.slug(:slug, field: :name)
             |> Map.get(:changes)
             |> Map.get(:slug) == "my-slug"
    end

    test "override if asked to override" do
      assert Changesetter.create(%{"name" => "A Name", "slug" => "my-slug"}, %{
               name: :string,
               slug: :string
             })
             |> Changesetter.slug(:slug, field: :name, override: true)
             |> Map.get(:changes)
             |> Map.get(:slug) == "a-name"
    end

    test "override if nulled out" do
      assert Changesetter.create(%{"name" => "A Name", "slug" => nil}, %{
               name: :string,
               slug: :string
             })
             |> Changesetter.slug(:slug, field: :name)
             |> Map.get(:changes)
             |> Map.get(:slug) == "a-name"
    end
  end
end
