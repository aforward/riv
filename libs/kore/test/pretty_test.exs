defmodule Kore.PrettyTest do
  use ExUnit.Case
  alias Kore.Pretty
  doctest Kore.Pretty

  describe "date/1" do
    test "nil" do
      assert Pretty.date(nil) == "--"
    end

    test "no padding" do
      assert Pretty.date(~N[2024-01-13 18:43:58]) == "Jan 13, 2024"
    end

    test "yes padding" do
      assert Pretty.date(~N[2024-01-04 18:43:58]) == "Jan 04, 2024"
    end

    test "handle strings" do
      assert Pretty.date("2024-01-04") == "Jan 04, 2024"
    end

    test "all months" do
      assert Pretty.date(~N[2024-01-04 18:43:58]) == "Jan 04, 2024"
      assert Pretty.date(~N[2024-02-04 18:43:58]) == "Feb 04, 2024"
      assert Pretty.date(~N[2024-03-04 18:43:58]) == "Mar 04, 2024"
      assert Pretty.date(~N[2024-04-04 18:43:58]) == "Apr 04, 2024"
      assert Pretty.date(~N[2024-05-04 18:43:58]) == "May 04, 2024"
      assert Pretty.date(~N[2024-06-04 18:43:58]) == "Jun 04, 2024"
      assert Pretty.date(~N[2024-07-04 18:43:58]) == "Jul 04, 2024"
      assert Pretty.date(~N[2024-08-04 18:43:58]) == "Aug 04, 2024"
      assert Pretty.date(~N[2024-09-04 18:43:58]) == "Sep 04, 2024"
      assert Pretty.date(~N[2024-10-04 18:43:58]) == "Oct 04, 2024"
      assert Pretty.date(~N[2024-11-04 18:43:58]) == "Nov 04, 2024"
      assert Pretty.date(~N[2024-12-04 18:43:58]) == "Dec 04, 2024"
    end
  end

  describe "datetime/1" do
    test "nil" do
      assert Pretty.datetime(nil) == "--"
    end

    test "no padding" do
      assert Pretty.datetime(~N[2024-01-13 18:43:58]) == "Jan 13, 2024 (18:43:58)"
    end

    test "yes padding" do
      assert Pretty.datetime(~N[2024-01-04 08:03:05]) == "Jan 04, 2024 (08:03:05)"
    end
  end

  describe "timedate/1" do
    test "nil" do
      assert Pretty.timedate(nil) == "--"
    end

    test "no padding" do
      assert Pretty.timedate(~N[2024-01-13 18:43:58]) == "18:43:58 (Jan 13, 2024)"
    end

    test "yes padding" do
      assert Pretty.timedate(~N[2024-01-04 08:03:05]) == "08:03:05 (Jan 04, 2024)"
    end
  end

  describe "money/2" do
    test "nil stays as nil" do
      assert Pretty.money(nil) == nil
    end

    test "support floats" do
      assert Pretty.money(12.819) == "$12.82"
    end

    test "support ints" do
      assert Pretty.money(12) == "$12.00"
    end

    test "support strings" do
      assert Pretty.money("12.8") == "$12.80"
    end

    test "adds commas" do
      assert Pretty.money(2_999_888_777.819) == "$2,999,888,777.82"
      assert Pretty.money(2_999_888_777, precision: 0) == "$2,999,888,777"
    end

    test "format to desired precision" do
      assert Pretty.money(12.819) == "$12.82"
      assert Pretty.money(12.819, precision: 0) == "$13"
      assert Pretty.money(12.819, precision: 1) == "$12.80"
      assert Pretty.money(12.819, precision: 2) == "$12.82"
    end

    test "format to desired precision :roundup_5" do
      assert Pretty.money(12.796, precision: :roundup_5) == "$12.80"
      assert Pretty.money(12.819, precision: :roundup_5) == "$12.85"
      assert Pretty.money(12.848, precision: :roundup_5) == "$12.85"
      assert Pretty.money(12.851, precision: :roundup_5) == "$12.85"
      assert Pretty.money(12.856, precision: :roundup_5) == "$12.90"
    end

    test "format to money symbol" do
      assert Pretty.money(12.82) == "$12.82"
      assert Pretty.money(12.82, currency: :usd) == "$12.82"
      assert Pretty.money(12.82, currency: :cad) == "$12.82"
      assert Pretty.money(12.82, currency: :gbp) == "£12.82"
      assert Pretty.money(12.82, currency: :eur) == "12.82€"
      assert Pretty.money(12.82, currency: :aud) == "$12.82"
    end

    test "format without money symbol" do
      assert Pretty.money(12.82, currency: nil) == "12.82"
    end

    test "format as string, decimal float or int" do
      assert Pretty.money(12.821, format: :string) == "$12.82"
      assert Pretty.money(12.821, format: :decimal) == Decimal.new("12.82")
      assert Pretty.money(12.821, format: :float) == 12.82
      assert Pretty.money(12.821, format: :integer) == 13
    end
  end

  describe "jsonable/1" do
    test "nil" do
      assert Pretty.jsonable(nil) == nil
    end

    test "primitive" do
      assert Pretty.jsonable(1) == 1
      assert Pretty.jsonable(2.1) == 2.1
      assert Pretty.jsonable("hello") == "hello"
    end

    test "atom" do
      assert Pretty.jsonable(:a) == "a"
    end

    test "boolean" do
      assert Pretty.jsonable(true) == true
      assert Pretty.jsonable(false) == false
    end

    test "dates" do
      assert Pretty.jsonable(%{a: ~U[2024-09-22 13:44:48Z]}) == %{"a" => "2024-09-22T13:44:48Z"}
      assert Pretty.jsonable(%{a: ~D[2021-09-21]}) == %{"a" => "2021-09-21"}
      assert Pretty.jsonable(%{a: ~N[2021-09-21 10:11:09]}) == %{"a" => "2021-09-21T10:11:09"}
      assert Pretty.jsonable(%{a: ~N[2024-09-22T00:00:00]}) == %{"a" => "2024-09-22"}
    end

    test "lists" do
      assert Pretty.jsonable([1, "a", 2]) == [1, "a", 2]
    end

    test "maps" do
      assert Pretty.jsonable(%{a: 1}) == %{"a" => 1}
    end

    test "tuple" do
      assert Pretty.jsonable({:a, 1, "c"}) == ["a", 1, "c"]
    end

    test "keyword list" do
      assert Pretty.jsonable(a: 1, b: 2) == ["a", 1, "b", 2]
    end

    test "nested" do
      assert Pretty.jsonable(%{a: [b: 1, c: 2], b: %{x: "10"}}) == %{
               "a" => ["b", 1, "c", 2],
               "b" => %{"x" => "10"}
             }
    end
  end
end
