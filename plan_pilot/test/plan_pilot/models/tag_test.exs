defmodule PlanPilot.Models.TagTest do
  use PlanPilot.DataCase, async: true
  alias PlanPilot.Models.{Tag, Template}
  doctest PlanPilot.Models.Tag

  describe "upsert/1" do
    test "add if new" do
      Tag.upsert(%{
        name: "abc123",
        templates: ["a", "b", "c"]
      })

      p = Tag.find("abc123")

      assert p.name == "abc123"
      assert p.templates == ["a", "b", "c"]
    end

    test "update if existing" do
      {:ok, original} =
        Tag.add(%{
          name: "abc123",
          templates: ["a", "b", "c"]
        })

      Tag.upsert(%{
        name: "abc123",
        templates: ["a", "c", "d"]
      })

      p = Tag.find("abc123")

      assert p.name == "abc123"
      assert p.templates == ["a", "c", "d"]

      assert p.id == original.id
    end

    test "create with templatelist" do
      Tag.upsert(%{
        name: "abc123",
        templatelist: "   a,   b  ,   c  "
      })

      p = Tag.find("abc123")
      assert p.templates == ["a", "b", "c"]
    end

    test "update with templatelist" do
      Tag.upsert(%{name: "abc123"})

      Tag.upsert(%{
        name: "abc123",
        templatelist: "   a,   b  ,   c  "
      })

      p = Tag.find("abc123")
      assert p.templates == ["a", "b", "c"]
    end
  end

  describe "add/1" do
    test "create if new" do
      Tag.add(%{
        name: "abc123",
        templates: ["a", "c", "d"]
      })

      p = Tag.find("abc123")

      assert p.name == "abc123"
      assert p.templates == ["a", "c", "d"]
    end

    test "default values" do
      {:ok, g} = Tag.add(%{})
      p = Tag.find(g.name)

      assert p.name == g.name
      assert p.templates == []
    end
  end

  describe "update/2" do
    test "update values" do
      {:ok, g} = Tag.add(%{name: "abc123"})

      Tag.update(g, %{
        name: "abc123",
        templates: ["a", "c", "d"]
      })

      p = Tag.find("abc123")

      assert p.id == g.id

      assert p.name == "abc123"
      assert p.templates == ["a", "c", "d"]
    end
  end

  describe "all/0" do
    test "none" do
      assert Tag.all() == []
    end

    test "some" do
      Tag.add(%{name: "a"})
      Tag.add(%{name: "z"})
      Tag.add(%{name: "m"})
      assert Tag.all() |> Enum.map(& &1.name) == ["a", "m", "z"]
    end
  end

  describe "find/x" do
    test "nil data" do
      assert is_nil(Tag.find(nil))
      assert is_nil(Tag.find(""))
    end

    test "find by name" do
      {:ok, e1} = Tag.add(%{name: "n1"})
      {:ok, e2} = Tag.add(%{name: "n2"})

      assert Tag.find(e1.name).id == e1.id
      assert Tag.find(e2.name).id == e2.id
    end
  end

  describe "refresh_all" do
    test "no templates" do
      Tag.add(%{name: "a"})
      Tag.refresh_all()
      assert Tag.all() == []
    end

    test "all new tags from all templates" do
      Template.add(%{name: "n1", tags: ["a", "b", "c"]})
      Template.add(%{name: "n2", tags: ["a", "d"]})
      Tag.refresh_all()
      assert Tag.all() |> Enum.map(& &1.name) == ["a", "b", "c", "d"]

      assert Tag.find("a").templates == ["n1", "n2"]
      assert Tag.find("b").templates == ["n1"]
      assert Tag.find("c").templates == ["n1"]
      assert Tag.find("d").templates == ["n2"]
    end

    test "delete old tags" do
      Tag.add(%{name: "a"})
      Template.add(%{name: "n1", tags: ["b", "c"]})
      Tag.refresh_all()
      assert Tag.all() |> Enum.map(& &1.name) == ["b", "c"]
    end

    test "keep existing tags" do
      Tag.add(%{name: "a"})
      Template.add(%{name: "n1", tags: ["a", "c"]})
      Tag.refresh_all()
      assert Tag.all() |> Enum.map(& &1.name) == ["a", "c"]
    end
  end
end
