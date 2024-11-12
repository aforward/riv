defmodule Kore.AppIntegrationTest do
  use ExUnit.Case, async: false
  alias Kore.{AppIntegration, InmemoryStore}
  doctest Kore.AppIntegration

  setup do
    start_supervised!(InmemoryStore)
    :ok
  end

  describe "upsert/1" do
    test "create if new" do
      AppIntegration.upsert(%{
        application: "googlesheets",
        oauth2_url: "http://api.local",
        client_name: "c",
        client_id: "a",
        client_secret: "b"
      })

      t = AppIntegration.find({"googlesheets", "c"})

      assert t.application == "googlesheets"
      assert t.client_name == "c"
      assert t.oauth2_url == "http://api.local"
      assert t.client_id == "a"
      assert t.client_secret == "b"
    end

    test "default values" do
      AppIntegration.upsert(%{application: "zoho", client_name: "n"})
      t = AppIntegration.find({"zoho", "n"})

      assert t.application == "zoho"
      assert t.oauth2_url == nil
      assert t.client_name == "n"
      assert t.client_id == nil
      assert t.client_secret == nil
    end

    test "update if existing" do
      AppIntegration.upsert(%{
        application: "salesforce",
        oauth2_url: "http://api.local",
        client_name: "c",
        client_id: "a",
        client_secret: "b"
      })

      AppIntegration.upsert(%{
        application: "salesforce",
        oauth2_url: "http://api2.local",
        client_name: "c",
        client_id: "a1",
        client_secret: "b1"
      })

      lookup_a = AppIntegration.find({"salesforce", "c"})

      assert lookup_a.application == "salesforce"
      assert lookup_a.oauth2_url == "http://api2.local"
      assert lookup_a.client_name == "c"
      assert lookup_a.client_id == "a1"
      assert lookup_a.client_secret == "b1"

      assert AppIntegration.all() |> Enum.map(& &1.client_name) == ["c"]

      assert AppIntegration.all_for_application("salesforce")
             |> Enum.map(& &1.client_name) == ["c"]
    end
  end

  describe "find/1" do
    test "not found" do
      assert is_nil(AppIntegration.find({"googlesheets", "a"}))
    end

    test "found" do
      AppIntegration.upsert(%{
        application: "googlesheets",
        oauth2_url: "http://api.local",
        client_name: "c",
        client_id: "a",
        client_secret: "b"
      })

      t = AppIntegration.find({"googlesheets", "c"})

      assert t.application == "googlesheets"
      assert t.oauth2_url == "http://api.local"
      assert t.client_id == "a"
      assert t.client_secret == "b"
      assert t.client_name == "c"
    end
  end

  describe "all" do
    test "none" do
      assert [] == AppIntegration.all()
    end

    test "some (for everyone)" do
      AppIntegration.upsert(%{application: "x", client_name: "a"})
      AppIntegration.upsert(%{application: "x", client_name: "z"})
      AppIntegration.upsert(%{application: "x", client_name: "m"})
      AppIntegration.upsert(%{application: "y", client_name: "b"})

      assert [{"x", "a"}, {"x", "m"}, {"x", "z"}, {"y", "b"}] ==
               AppIntegration.all() |> Enum.map(fn i -> {i.application, i.client_name} end)
    end

    test "some (application or client specific)" do
      AppIntegration.upsert(%{application: "a", client_name: "y"})
      AppIntegration.upsert(%{application: "a", client_name: "x"})
      AppIntegration.upsert(%{application: "b", client_name: "x"})

      assert [{"a", "x"}, {"a", "y"}, {"b", "x"}] ==
               AppIntegration.all() |> Enum.map(fn t -> {t.application, t.client_name} end)

      assert [{"a", "x"}, {"b", "x"}] ==
               AppIntegration.all_for_client("x")
               |> Enum.map(fn t -> {t.application, t.client_name} end)

      assert [{"a", "x"}, {"a", "y"}] ==
               AppIntegration.all_for_application("a")
               |> Enum.map(fn t -> {t.application, t.client_name} end)
    end
  end
end
