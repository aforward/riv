defmodule PlanPilot.Models.TemplateTest do
  use PlanPilot.DataCase, async: true
  alias PlanPilot.Models.Template
  doctest PlanPilot.Models.Template

  describe "upsert/1" do
    test "add if new" do
      Template.upsert(%{
        identifier: "abc123",
        name: "Mega Corp",
        slug: "mega-corp",
        text: "Hello {fname}, {lname}",
        placeholders: ["fname", "lname"]
      })

      p = Template.find("abc123")

      assert p.identifier == "abc123"
      assert p.name == "Mega Corp"
      assert p.slug == "mega-corp"
      assert p.text == "Hello {fname}, {lname}"
      assert p.placeholders == ["fname", "lname"]
    end

    test "update if existing" do
      {:ok, original} =
        Template.add(%{
          identifier: "abc123",
          name: "Mega Corp",
          slug: "mega-corp",
          text: "Hello {fname}, {lname}",
          placeholders: ["fname", "lname"]
        })

      Template.upsert(%{
        identifier: "abc123",
        name: "Giga Corp",
        slug: "giga-corp",
        text: "Goodbye {fullname}",
        placeholders: ["fullname"]
      })

      p = Template.find("abc123")

      assert p.identifier == "abc123"
      assert p.name == "Giga Corp"
      assert p.slug == "giga-corp"
      assert p.text == "Goodbye {fullname}"
      assert p.placeholders == ["fullname"]

      assert p.id == original.id
    end
  end

  describe "add/1" do
    test "create if new" do
      Template.add(%{
        identifier: "abc123",
        name: "Mega Corp",
        slug: "mega-corp",
        text: "Hello {fname}, {lname}",
        placeholders: ["fname", "lname"]
      })

      p = Template.find("abc123")

      assert p.identifier == "abc123"
      assert p.name == "Mega Corp"
      assert p.slug == "mega-corp"
      assert p.text == "Hello {fname}, {lname}"
      assert p.placeholders == ["fname", "lname"]
    end

    test "default values" do
      {:ok, g} = Template.add(%{})
      p = Template.find(g.identifier)

      assert p.identifier == g.identifier
      assert p.name == nil
      assert p.slug == nil
      assert p.text == nil
      assert p.placeholders == []
    end

    test "set slug" do
      {:ok, g} = Template.add(%{name: "My Name"})
      p = Template.find(g.identifier)

      assert p.identifier == g.identifier
      assert p.name == "My Name"
      assert p.slug == "my-name"
      assert p.text == nil
      assert p.placeholders == []
    end

    test "set placeholders" do
      {:ok, g} = Template.add(%{text: "My {fname} {lname}"})
      p = Template.find(g.identifier)

      assert p.identifier == g.identifier
      assert p.name == nil
      assert p.slug == nil
      assert p.text == "My {fname} {lname}"
      assert p.placeholders == ["fname", "lname"]
    end
  end

  describe "update/2" do
    test "update values" do
      {:ok, g} = Template.add(%{identifier: "abc123"})

      Template.update(g, %{
        identifier: "abc123",
        name: "Mega Corp",
        slug: "mega-corp",
        text: "Hello {fname}, {lname}",
        placeholders: ["fname", "lname"]
      })

      p = Template.find("abc123")

      assert p.id == g.id

      assert p.identifier == "abc123"
      assert p.name == "Mega Corp"
      assert p.slug == "mega-corp"
      assert p.text == "Hello {fname}, {lname}"
      assert p.placeholders == ["fname", "lname"]
    end
  end

  describe "all/0" do
    test "none" do
      assert Template.all() == []
    end

    test "some" do
      Template.add(%{name: "a"})
      Template.add(%{name: "z"})
      Template.add(%{name: "m"})
      assert Template.all() |> Enum.map(& &1.name) == ["a", "m", "z"]
    end
  end

  describe "find/x" do
    test "nil data" do
      assert is_nil(Template.find(nil))
      assert is_nil(Template.find(""))
    end

    test "find by identifier" do
      {:ok, e1} = Template.add(%{name: "n1"})
      {:ok, e2} = Template.add(%{name: "n2"})

      assert Template.find(e1.identifier).id == e1.id
      assert Template.find(e2.identifier).id == e2.id
    end
  end
end
