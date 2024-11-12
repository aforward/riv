defmodule Kore.AppTokenTest do
  use ExUnit.Case, async: false
  alias Kore.{AppToken, InmemoryStore}
  doctest Kore.AppToken

  setup do
    start_supervised!(InmemoryStore)
    :ok
  end

  describe "upsert/1" do
    test "create if new" do
      AppToken.upsert(%{
        application: "googlesheets",
        api_domain: "a",
        access_token: "b",
        expires_in: 10,
        refresh_token: "c",
        scope: "d",
        token_type: "e"
      })

      t = AppToken.find("googlesheets")

      assert t.application == "googlesheets"
      assert t.api_domain == "a"
      assert t.access_token == "b"
      assert t.expires_in == 10
      assert t.refresh_token == "c"
      assert t.scope == "d"
      assert t.token_type == "e"
    end

    test "default values" do
      AppToken.upsert(%{application: "zoho"})
      t = AppToken.find("zoho")

      assert t.application == "zoho"
      assert t.api_domain == nil
      assert t.access_token == nil
      assert t.expires_in == nil
      assert t.refresh_token == nil
      assert t.scope == nil
      assert t.token_type == nil
    end

    test "update if existing" do
      AppToken.upsert(%{
        application: "salesforce",
        api_domain: "a",
        access_token: "b",
        expires_in: 10,
        refresh_token: "c",
        scope: "d",
        token_type: "e"
      })

      AppToken.upsert(%{
        application: "salesforce",
        api_domain: "a1",
        access_token: "b1",
        expires_in: 11,
        refresh_token: "c1",
        scope: "d1",
        token_type: "e1"
      })

      lookup_a = AppToken.find("salesforce")

      assert lookup_a.application == "salesforce"
      assert lookup_a.api_domain == "a1"
      assert lookup_a.access_token == "b1"
      assert lookup_a.expires_in == 11
      assert lookup_a.refresh_token == "c1"
      assert lookup_a.scope == "d1"
      assert lookup_a.token_type == "e1"

      assert AppToken.all() |> Enum.map(& &1.application) == ["salesforce"]
    end

    test "upsert googlecloud :ok" do
      answer =
        {:ok,
         %{
           "access_token" => "x",
           "expires_in" => 3599,
           "refresh_token" => "y",
           "scope" => "z",
           "token_type" => "Bearer"
         }}

      {:ok, t} = AppToken.upsert(answer, "googlecloud")

      assert t.application == "googlecloud"
      assert t.access_token == "x"
      assert t.expires_in == 3599
      assert t.refresh_token == "y"
      assert t.scope == "z"
      assert t.token_type == "Bearer"
    end

    test "upsert googlecloud :error" do
      answer = {:error, %{"error" => "invalid_grant", "error_description" => "Bad Request"}}

      {:error, "invalid_grant"} = AppToken.upsert(answer, "googlecloud")
    end

    test "upsert zoho :error" do
      answer = {:error, "invalid_code"}

      {:error, "invalid_code"} = AppToken.upsert(answer, "zoho")
    end

    test "via {:ok, data}" do
      {:ok, t} =
        AppToken.upsert(
          {:ok,
           %{
             "api_domain" => "a",
             "access_token" => "b",
             "expires_in" => 10,
             "refresh_token" => "c",
             "scope" => "d",
             "token_type" => "e"
           }},
          "googlecloud"
        )

      assert t.application == "googlecloud"
      assert t.api_domain == "a"
      assert t.access_token == "b"
      assert t.expires_in == 10
      assert t.refresh_token == "c"
      assert t.scope == "d"
      assert t.token_type == "e"
    end
  end

  describe "find/1" do
    test "not found" do
      assert is_nil(AppToken.find("googlesheets"))
    end

    test "found" do
      AppToken.upsert(%{
        application: "googlesheets",
        api_domain: "a",
        access_token: "b",
        expires_in: 10,
        refresh_token: "c",
        scope: "d",
        token_type: "e"
      })

      t = AppToken.find("googlesheets")

      assert t.application == "googlesheets"
      assert t.api_domain == "a"
      assert t.access_token == "b"
      assert t.expires_in == 10
      assert t.refresh_token == "c"
      assert t.scope == "d"
      assert t.token_type == "e"
    end
  end

  describe "all" do
    test "none" do
      assert [] == AppToken.all()
    end

    test "some" do
      AppToken.upsert(%{application: "a"})
      AppToken.upsert(%{application: "z"})
      AppToken.upsert(%{application: "m"})
      assert ["a", "m", "z"] == AppToken.all() |> Enum.map(fn t -> t.application end)
    end
  end
end
