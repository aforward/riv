defmodule Kore.Pretty do
  def date(nil), do: "--"

  def date(s) when is_binary(s) do
    case Date.from_iso8601(s) do
      {:ok, d} -> date(d)
      {:error, _} -> date(nil)
    end
  end

  def date(n) do
    "#{month_to_string(n.month)} #{pad(n.day)}, #{n.year}"
  end

  def datetime(nil), do: "--"

  def datetime(n) do
    "#{date(n)} (#{pad(n.hour)}:#{pad(n.minute)}:#{pad(n.second)})"
  end

  def timedate(nil), do: "--"

  def timedate(n) do
    "#{pad(n.hour)}:#{pad(n.minute)}:#{pad(n.second)} (#{date(n)})"
  end

  def money(raw), do: money(raw, [])
  def money(nil, _opts), do: nil

  def money(float, opts) when is_float(float) do
    float
    |> Decimal.from_float()
    |> money(opts)
  end

  def money(amount, opts) do
    format = Keyword.get(opts, :format, :string)
    precision = Keyword.get(opts, :precision, 2)
    currency = Keyword.get(opts, :currency, :cad)

    {precision, currency} =
      case format do
        :integer ->
          {0, nil}

        :decimal ->
          {precision, nil}

        :float ->
          {precision, nil}

        :string ->
          {precision, currency}
      end

    amount
    |> round(precision)
    |> Decimal.to_string(:normal)
    |> ensure_precision(precision)
    |> then(fn a ->
      case format do
        :string ->
          [whole | fraction] = String.split(a, ".")

          whole
          |> String.graphemes()
          |> Enum.reverse()
          |> Enum.chunk_every(3)
          |> Enum.join(",")
          |> String.reverse()
          |> then(fn whole ->
            if fraction == [] do
              whole
            else
              "#{whole}.#{fraction}"
            end
          end)
          |> add_currency(currency)

        :decimal ->
          Decimal.new(a)

        :float ->
          Decimal.new(a) |> Decimal.to_float()

        :integer ->
          Decimal.new(a) |> Decimal.to_integer()
      end
    end)
  end

  def jsonable(d) do
    cond do
      d == true || d == false -> d
      is_nil(d) -> nil
      is_struct(d, DateTime) -> DateTime.to_iso8601(d)
      is_struct(d, Date) -> Date.to_iso8601(d)
      is_struct(d, NaiveDateTime) && !time?(d) -> d |> NaiveDateTime.to_date() |> Date.to_string()
      is_struct(d, NaiveDateTime) -> NaiveDateTime.to_iso8601(d)
      is_tuple(d) -> Tuple.to_list(d) |> jsonable()
      is_list(d) -> Enum.map(d, &jsonable/1) |> List.flatten()
      is_map(d) -> Enum.map(d, fn {k, v} -> {jsonable(k), jsonable(v)} end) |> Enum.into(%{})
      is_atom(d) -> Atom.to_string(d)
      :else -> d
    end
  end

  defp month_to_string(month) when month in 1..12 do
    ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    |> Enum.at(month - 1)
  end

  # Ensures day of the month is always two digits
  defp pad(number) when number < 10, do: "0#{number}"
  defp pad(number), do: to_string(number)

  defp round(amount, :roundup_5) do
    amount
    |> Decimal.round(2)
    |> Decimal.mult(100)
    |> Decimal.to_integer()
    |> then(fn cents ->
      case rem(cents, 5) do
        0 -> cents
        diff -> cents + 5 - diff
      end
    end)
    |> Decimal.new()
    |> Decimal.div(100)
  end

  defp round(amount, precision), do: Decimal.round(amount, precision)

  defp ensure_precision(amount, 0), do: amount

  defp ensure_precision(amount, _) do
    case String.split(amount, ".") do
      [w] -> "#{w}.#{String.pad_trailing("", 2, "0")}"
      [w, f] -> "#{w}.#{String.pad_trailing(f, 2, "0")}"
    end
  end

  defp add_currency(amount, nil), do: amount
  defp add_currency(amount, :usd), do: "$#{amount}"
  defp add_currency(amount, :cad), do: "$#{amount}"
  defp add_currency(amount, :gbp), do: "£#{amount}"
  defp add_currency(amount, :eur), do: "#{amount}€"
  defp add_currency(amount, :aud), do: "$#{amount}"

  defp time?(n), do: n.hour != 0 || n.minute != 0 || n.second != 0
end
