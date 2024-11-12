defmodule Kore.InmemoryStoreTest do
  use ExUnit.Case, async: false
  alias Kore.InmemoryStore
  doctest InmemoryStore, import: true

  setup do
    start_supervised!(InmemoryStore)
    :ok
  end

  describe "get/set" do
    test "does not exists" do
      assert InmemoryStore.get(:k) == nil
    end

    test "allow for a default" do
      assert InmemoryStore.get(:states, []) == []
      InmemoryStore.set(:states, ["a", "b"])
      assert InmemoryStore.get(:states, []) == ["a", "b"]
      InmemoryStore.set(:states, nil)
      assert InmemoryStore.get(:states, []) == nil
    end

    test "does exists" do
      InmemoryStore.set(:k, "vvvvv")
      assert InmemoryStore.get(:k) == "vvvvv"
    end
  end

  describe "keys" do
    test "none" do
      assert InmemoryStore.keys() == []
    end

    test "some" do
      InmemoryStore.set(:k, "vvvvv")
      InmemoryStore.set(:m, "wwwww")
      assert InmemoryStore.keys() == [:k, :m]
    end
  end

  describe "delete" do
    test "does not exist" do
      assert InmemoryStore.delete(:k) == :ok
      assert InmemoryStore.get(:k) == nil
    end

    test "some" do
      InmemoryStore.set(:k, "vvvvv")
      assert InmemoryStore.delete(:k) == :ok
      assert InmemoryStore.get(:k) == nil
    end
  end

  describe "update" do
    test "new" do
      InmemoryStore.update(:k, "a", fn v -> "#{v}x" end)
      assert InmemoryStore.get(:k) == "a"
    end

    test "override" do
      InmemoryStore.set(:k, "b")
      InmemoryStore.update(:k, "a", fn v -> "#{v}x" end)
      assert InmemoryStore.get(:k) == "bx"
    end
  end
end
