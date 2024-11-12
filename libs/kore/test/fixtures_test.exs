defmodule Kore.FixturesTest do
  use ExUnit.Case
  alias Kore.Fixtures
  doctest Fixtures

  describe "exists?/1" do
    test "not found" do
      assert !Fixtures.exists?("./test/fixtures/missing.json")
    end

    test "found" do
      assert Fixtures.exists?("./test/fixtures/one.json")
    end
  end

  describe "load_json/2" do
    test "not found" do
      assert Fixtures.load_json("./test/fixtures/missing.json") == nil
      assert Fixtures.load_json("./test/fixtures/missing.json", :goop) == :goop
    end

    test "found" do
      assert Fixtures.load_json("./test/fixtures/one.json") == %{"a" => 1, "b" => "two"}
      assert Fixtures.load_json("./test/fixtures/one.json", :goop) == %{"a" => 1, "b" => "two"}
    end
  end

  describe "token_path/1" do
    test "assume structure" do
      assert Fixtures.token_path("a") == "./test/fixtures/a_token.json"
      assert Fixtures.token_path("b") == "./test/fixtures/b_token.json"
    end
  end

  describe "fixture_token?/1" do
    test "not found" do
      assert !Fixtures.fixture_token?("a")
    end

    test "found" do
      assert Fixtures.fixture_token?("sample")
    end
  end

  describe "fixture_token/1" do
    test "not found" do
      assert Fixtures.fixture_token("a") == %{}
    end

    test "found" do
      assert Fixtures.fixture_token("sample") == %{"token" => "abc123", "application" => "sample"}
    end
  end
end
