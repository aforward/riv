defmodule Kore.ConfigTest do
  use ExUnit.Case, async: true
  alias Kore.Config
  doctest Kore.Config

  @env_vars [
    "ADMIN_PASSWORD",
    "GOOGLECLOUD_PROJECT_ID",
    "GOOGLECLOUD_CLIENT_ID",
    "GOOGLECLOUD_CLIENT_SECRET",
    "GOOGLECLOUD_REDIRECT_URI",
    "ZOHO_CLIENT_ID",
    "ZOHO_CLIENT_SECRET",
    "ZOHO_REDIRECT_URI",
    "CLOAK_KEY",
    "CLOAK_KEY_V9"
  ]

  setup do
    env_vars = Kore.Config.backup(@env_vars)
    on_exit(fn -> Kore.Config.restore(env_vars) end)
  end

  describe "all/1" do
    test "it should load from env vars" do
      Config.restore(%{
        "ADMIN_PASSWORD" => "0",
        "ZOHO_CLIENT_ID" => "a",
        "ZOHO_CLIENT_SECRET" => "b",
        "ZOHO_REDIRECT_URI" => "c",
        "GOOGLECLOUD_PROJECT_ID" => "d",
        "GOOGLECLOUD_CLIENT_ID" => "e",
        "GOOGLECLOUD_CLIENT_SECRET" => "f",
        "GOOGLECLOUD_REDIRECT_URI" => "g",
        "CLOAK_KEY" => "h",
        "CLOAK_KEY_V9" => "i"
      })

      assert %{
               "ADMIN_PASSWORD" => "0",
               "ZOHO_CLIENT_ID" => "a",
               "ZOHO_CLIENT_SECRET" => "b",
               "ZOHO_REDIRECT_URI" => "c",
               "GOOGLECLOUD_PROJECT_ID" => "d",
               "GOOGLECLOUD_CLIENT_ID" => "e",
               "GOOGLECLOUD_CLIENT_SECRET" => "f",
               "GOOGLECLOUD_REDIRECT_URI" => "g",
               "CLOAK_KEY" => "h",
               "CLOAK_KEY_V9" => "i"
             } ==
               Config.all(@env_vars)
    end
  end

  describe "replace" do
    test "replace env A with B and return the original values" do
      Config.restore(%{
        "ADMIN_PASSWORD" => "keep-me",
        "ZOHO_CLIENT_ID" => "real-a",
        "ZOHO_CLIENT_SECRET" => "real-b",
        "ZOHO_REDIRECT_URI" => "real-c",
        "ZOHO_TEST_CLIENT_ID" => "test-a",
        "ZOHO_TEST_CLIENT_SECRET" => "test-b",
        "ZOHO_TEST_REDIRECT_URI" => "test-c"
      })

      backups =
        Config.replace(%{
          "ZOHO_CLIENT_ID" => "ZOHO_TEST_CLIENT_ID",
          "ZOHO_CLIENT_SECRET" => "ZOHO_TEST_CLIENT_SECRET",
          "ZOHO_REDIRECT_URI" => "ZOHO_TEST_REDIRECT_URI"
        })

      assert backups == %{
               "ZOHO_CLIENT_ID" => "real-a",
               "ZOHO_CLIENT_SECRET" => "real-b",
               "ZOHO_REDIRECT_URI" => "real-c"
             }

      assert Config.all(@env_vars) == %{
               "ADMIN_PASSWORD" => "keep-me",
               "GOOGLECLOUD_CLIENT_ID" => nil,
               "GOOGLECLOUD_CLIENT_SECRET" => nil,
               "GOOGLECLOUD_PROJECT_ID" => nil,
               "GOOGLECLOUD_REDIRECT_URI" => nil,
               "ZOHO_CLIENT_ID" => "test-a",
               "ZOHO_CLIENT_SECRET" => "test-b",
               "ZOHO_REDIRECT_URI" => "test-c",
               "CLOAK_KEY" => nil,
               "CLOAK_KEY_V9" => nil
             }
    end

    test "support nil" do
      Config.replace(%{"SOME_VAL" => "IGNORE"})
      assert System.get_env("SOME_VAL") == nil
    end
  end

  describe "cloak_key" do
    test "should default to know value for testing" do
      assert Kore.Config.cloak_key() ==
               Base.decode64!("32jyWHPEsjc4w4gUX5fG2hDy9n5v88YPXp7oYGR8huk=")

      assert Kore.Config.cloak_key(nil) ==
               Base.decode64!("32jyWHPEsjc4w4gUX5fG2hDy9n5v88YPXp7oYGR8huk=")
    end

    test "lookup default value" do
      key = "WMNh3KqNSSh/RoTx3VhpG/lNkF+HB0vIHklw+S/En3Y="
      Config.restore(%{"CLOAK_KEY" => key})

      assert Kore.Config.cloak_key() == Base.decode64!(key)
      assert Kore.Config.cloak_key(nil) == Base.decode64!(key)
    end

    test "lookup a specific version" do
      key_v1 = "WMNh3KqNSSh/RoTx3VhpG/lNkF+HB0vIHklw+S/En3Y="
      key_v9 = "MY9dA2n8fiQSvNb3Im80wRCR6x/qtAFabc4TNfJv0VY="
      Config.restore(%{"CLOAK_KEY" => key_v1, "CLOAK_KEY_V9" => key_v9})

      assert Kore.Config.cloak_key("V9") == Base.decode64!(key_v9)
    end
  end
end
