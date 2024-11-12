defmodule Kore.Timestamp do
  @day_offset %{
    monday: 1,
    tuesday: 2,
    wednesday: 3,
    thursday: 4,
    friday: 5,
    saturday: 6,
    sunday: 0
  }

  def date(day), do: date(day, 0)

  def date(:today, offset), do: date(NaiveDateTime.local_now(), offset)

  def date(day, offset) when is_binary(day) do
    {ok_day, date} = Date.from_iso8601(day)
    {ok_day_time, date_time} = NaiveDateTime.from_iso8601(day)

    cond do
      ok_day == :ok -> date(date, offset)
      ok_day_time == :ok -> NaiveDateTime.add(date_time, days_in_seconds(offset), :second)
      :else -> nil
    end
  end

  def date(day, day_of_week) when is_atom(day_of_week) do
    date(day, day_of_week_offset(day, day_of_week))
  end

  def date(day, offset) do
    day
    |> Date.add(offset)
    |> Date.to_iso8601()
    |> (&"#{&1} 00:00:00").()
    |> NaiveDateTime.from_iso8601!()
  end

  def datetime(:now), do: NaiveDateTime.local_now()
  def datetime(day), do: datetime(day, 0, 0, 0)
  def datetime(day, day_offset), do: datetime(day, day_offset, 0, 0)
  def datetime(day, day_offset, hour_offset), do: datetime(day, day_offset, hour_offset, 0)

  def datetime(:today, day_offset, hour_offset, minute_offset) do
    NaiveDateTime.local_now()
    |> Date.to_iso8601()
    |> datetime(day_offset, hour_offset, minute_offset)
  end

  def datetime(day, day_offset, hour_offset, minute_offset) when is_binary(day) do
    case Date.from_iso8601(day) do
      {:ok, day} -> {:ok, day}
      {:error, _err} -> NaiveDateTime.from_iso8601(day)
    end
    |> case do
      {:ok, day_or_datetime} ->
        datetime(day_or_datetime, day_offset, hour_offset, minute_offset)

      {:error, _} ->
        nil
    end
  end

  def datetime(day, day_of_week, hour_offset, minute_offset) when is_atom(day_of_week) do
    day_offset = day_of_week_offset(day, day_of_week)
    datetime(day, day_offset, hour_offset, minute_offset)
  end

  def datetime(%Date{} = day, day_offset, hour_offset, minute_offset) do
    day
    |> (&"#{&1} 00:00:00").()
    |> NaiveDateTime.from_iso8601!()
    |> datetime(day_offset, hour_offset, minute_offset)
  end

  def datetime(%NaiveDateTime{} = datetime, day_offset, hour_offset, minute_offset) do
    datetime
    |> NaiveDateTime.add(days_in_seconds(day_offset), :second)
    |> NaiveDateTime.add(hours_in_seconds(hour_offset), :second)
    |> NaiveDateTime.add(minutes_in_seconds(minute_offset), :second)
  end

  def datetimeutc(nil), do: nil

  def datetimeutc(utc) when is_binary(utc) do
    case DateTime.from_iso8601(utc) do
      {:ok, datetime, _offset} ->
        datetime

      _err ->
        nil
    end
  end

  @doc """
  To use this correctly, add the following to your confix.exs

      config :elixir, :time_zone_database, TimeZoneInfo.TimeZoneDatabase

  Or, if not a config then

      Calendar.put_time_zone_database(TimeZoneInfo.TimeZoneDatabase)
  """
  def datetimeutc(%NaiveDateTime{} = naive, tz) do
    case DateTime.from_naive(naive, tz) do
      {:ok, d} ->
        DateTime.shift_zone!(d, "Etc/UTC")

      {:error, :time_zone_not_found} ->
        default_datetimeutc(naive)

      {:error, :utc_only_time_zone_database} ->
        default_datetimeutc(naive)
    end
  end

  def datetimeutc({dt, offset}, tz), do: datetimeutc(datetime(dt, offset), tz)
  def datetimeutc(dt, tz), do: datetimeutc(datetime(dt), tz)

  defp default_datetimeutc(%NaiveDateTime{} = naive) do
    {:ok, d} = DateTime.from_naive(naive, "Etc/UTC")
    d
  end

  @doc """
  To use this correctly, add the following to your confix.exs

      config :elixir, :time_zone_database, TimeZoneInfo.TimeZoneDatabase

  Or, if not a config then

      Calendar.put_time_zone_database(TimeZoneInfo.TimeZoneDatabase)
  """
  def datetimegmt(dt, tz) do
    dt
    |> datetimeutc(tz)
    |> then(fn gmt ->
      date = Calendar.strftime(gmt, "%Y-%m-%dT%I:%M:%S")
      {prefix, suffix} = Calendar.strftime(gmt, "%z") |> String.split_at(3)
      "#{date} GMT#{prefix}:#{suffix}"
    end)
  end

  def day(day), do: day(day, 0)

  def day(day, offset) do
    day
    |> date(offset)
    |> NaiveDateTime.to_erl()
    |> case do
      {parts, _} -> Date.from_erl(parts)
    end
    |> case do
      {:ok, day} -> day
    end
  end

  def same?(t1, t2, precision) do
    diff = abs(NaiveDateTime.diff(t1, t2))

    case precision do
      :second -> diff == 0
      :minute -> diff <= 60
      :hour -> diff <= 60 * 60
      :day -> diff <= 60 * 60 * 24
    end
  end

  def day_of_week_offset(day, day_of_week) do
    case rem(@day_offset[day_of_week] - Date.day_of_week(day) + 7, 7) do
      # always in the future
      0 -> 7
      # otherwise it's in a few days
      n -> n
    end
  end

  defp days_in_seconds(num_days), do: num_days * 60 * 60 * 24
  defp hours_in_seconds(num_hours), do: num_hours * 60 * 60
  defp minutes_in_seconds(num_minutes), do: num_minutes * 60
end
