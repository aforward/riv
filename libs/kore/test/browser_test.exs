defmodule Kore.BrowserTest do
  use ExUnit.Case, async: false
  alias Kore.Browser
  doctest Kore.Browser

  describe "query_params/1" do
    test "handle nil" do
      assert Browser.query_params(nil) == %{}
    end

    test "handle goop" do
      assert Browser.query_params("goop") == %{}
    end

    test "extract all parts" do
      assert Browser.query_params(
               "http://localhost:4000/auth/zoho?code=1000.aaa.bbb&location=us&accounts-server=https%3A%2F%2Faccounts.zoho.com&"
             ) ==
               %{
                 "code" => "1000.aaa.bbb",
                 "location" => "us",
                 "accounts-server" => "https://accounts.zoho.com"
               }
    end
  end

  describe "write_fixture_token/2" do
    test "save to file directly" do
      path =
        Path.join(
          System.tmp_dir!(),
          "browser_test_store_fixutre_token_2_#{:erlang.unique_integer([:positive])}.json"
        )

      Browser.write_fixture_token(%{"a" => 1, "b" => 2}, path)

      assert File.read!(path) == Jason.encode!(%{"a" => 1, "b" => 2}, pretty: true)
    end

    test "extract {:ok, data} as just data" do
      path =
        Path.join(
          System.tmp_dir!(),
          "browser_test_store_fixutre_token_2_#{:erlang.unique_integer([:positive])}.json"
        )

      Browser.write_fixture_token({:ok, %{"a" => 1, "b" => 2}}, path)

      assert File.read!(path) == Jason.encode!(%{"a" => 1, "b" => 2}, pretty: true)
    end
  end
end
