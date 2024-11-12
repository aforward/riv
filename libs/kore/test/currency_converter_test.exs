defmodule Kore.CurrencyConverterTest do
  use ExUnit.Case
  alias Kore.CurrencyConverter
  doctest CurrencyConverter

  defmodule MyStuff do
    defstruct [:name, :days]
  end

  describe "convert/x" do
    test "handle nil" do
      assert CurrencyConverter.convert(nil, 0.5) == nil
      assert CurrencyConverter.convert(nil, 0.5, []) == nil
    end

    test "single value" do
      assert CurrencyConverter.convert(10, 0.5) == 5
      assert CurrencyConverter.convert(10, 1 / 3) == 3.33
    end

    test "list of values" do
      assert CurrencyConverter.convert([10, 20], 0.5) == [5, 10]
    end

    test "map of values" do
      finacials = %{
        days: [1, 2, 3, 4, 5, 6, 7],
        custom_outer_box: 8,
        labour: 9,
        inside_crinkle_paper: 10,
        card: 11,
        donation: 12,
        inner_box: 13
      }

      assert CurrencyConverter.convert(finacials, 2) == %{
               days: [2, 4, 6, 8, 10, 12, 14],
               custom_outer_box: 16,
               labour: 18,
               inside_crinkle_paper: 20,
               card: 22,
               donation: 24,
               inner_box: 26
             }
    end

    test "filtered map" do
      finacials = %{
        days: [1, 2, 3, 4, 5, 6, 7],
        name: "A"
      }

      assert CurrencyConverter.convert(finacials, 2, [:days]) == %{
               days: [2, 4, 6, 8, 10, 12, 14],
               name: "A"
             }
    end

    test "struct" do
      finacials = %MyStuff{
        days: [1, 2, 3, 4, 5, 6, 7],
        name: "A"
      }

      assert CurrencyConverter.convert(finacials, 2, [:days]) == %MyStuff{
               days: [2, 4, 6, 8, 10, 12, 14],
               name: "A"
             }
    end
  end
end
