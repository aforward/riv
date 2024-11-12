defmodule KoreTest do
  use ExUnit.Case
  doctest Kore

  describe "map_get/x" do
    test "not found" do
      assert is_nil(Kore.map_get(%{a: 1}, :b))
    end

    test "found by atom OR string" do
      assert Kore.map_get(%{a: 1}, :a) == 1
      assert Kore.map_get(%{"a" => 1}, :a) == 1
    end

    test "allow default" do
      assert Kore.map_get(%{a: 1}, :a, :x) == 1
      assert Kore.map_get(%{"a" => 1}, :a, :x) == 1
      assert Kore.map_get(%{"a" => 1}, :b, :x) == :x
    end
  end

  describe "person_names/1" do
    test "nil is all nil" do
      assert Kore.person_names(nil) == [nil, nil, nil]
    end

    test "one name" do
      assert Kore.person_names("James") == ["James", "", "James"]
    end

    test "two names" do
      assert Kore.person_names("James Url") == ["James Url", "James", "Url"]
    end

    test "more than 2 names" do
      assert Kore.person_names("James Url Jones") == ["James Url Jones", "James", "Url Jones"]
    end
  end
end
