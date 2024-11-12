defmodule Kore.AppCodeTest do
  use ExUnit.Case, async: false
  alias Kore.{AppCode, InmemoryStore}
  doctest Kore.AppCode

  setup do
    start_supervised!(InmemoryStore)
    :ok
  end

  describe "create/x" do
    test "a nice long random code" do
      code1 = AppCode.create(%{a: 1, b: 1})
      code2 = AppCode.create(%{a: 1, b: 1})
      assert code1 != code2
      assert String.length(code1) >= 20
    end

    test "take a set of data to lookup" do
      code = AppCode.create(%{a: 1, b: 1})
      assert AppCode.exists?(code) == true
    end

    test "allow no data to be provided" do
      code = AppCode.create()
      assert AppCode.exists?(code) == true
    end
  end

  describe "peek/0" do
    test "no codes created" do
      assert is_nil(AppCode.peek())
    end

    test "pop the last code off" do
      code1 = AppCode.create(%{a: 1, b: 1})
      assert code1 == AppCode.peek()
      code2 = AppCode.create(%{a: 1, b: 1})
      assert code2 == AppCode.peek()

      AppCode.verify(code2)
      assert code1 == AppCode.peek()
    end
  end

  describe "exists?/1" do
    test "check if the code exists" do
      code1 = AppCode.create(%{a: 1, b: 1})
      code2 = "xxxyyy"

      assert AppCode.exists?(code1) == true
      assert AppCode.exists?(code1) == true
      assert AppCode.exists?(code2) == false
    end
  end

  describe "find/1" do
    test "check if the code exists" do
      code1 = AppCode.create(%{a: 1, b: 1})
      code2 = AppCode.create()
      code3 = "xxxyyy"

      assert AppCode.find(code1) == %{a: 1, b: 1}
      assert AppCode.find(code2) == :ok
      assert AppCode.find(code3) == nil
    end
  end

  describe "verify/1" do
    test "does not exist" do
      assert AppCode.verify("xxxyyy") == {:error, :unknown_code}
    end

    test "can only verify once" do
      code = AppCode.create()
      assert AppCode.verify(code) == {:ok, :ok}
      assert AppCode.verify(code) == {:error, :unknown_code}
    end

    test "return the stored data" do
      code = AppCode.create(%{a: 1})
      assert AppCode.verify(code) == {:ok, %{a: 1}}
    end

    test "can verify against original data as well (match)" do
      code = AppCode.create(%{a: 1, b: 1})
      assert AppCode.verify(code, %{a: 1, b: 1}) == {:ok, %{a: 1, b: 1}}
    end

    test "verify can be rejected if original data mismatches" do
      code = AppCode.create(%{a: 1, b: 1})
      assert AppCode.verify(code, %{a: 1, b: 2}) == {:error, :lookup_mismatch}
      # only 1 chance
      assert AppCode.verify(code, %{a: 1, b: 1}) == {:error, :unknown_code}
    end
  end

  describe "all" do
    test "none" do
      assert [] == AppCode.all()
    end

    test "some" do
      code1 = AppCode.create(%{app: "a"})
      code2 = AppCode.create()
      code3 = AppCode.create(%{app: "m"})

      assert AppCode.all() == [
               {code3, %{app: "m"}},
               {code2, :ok},
               {code1, %{app: "a"}}
             ]
    end
  end
end
