defmodule Kore.TimestampTest do
  use ExUnit.Case, async: false
  alias Kore.Timestamp
  doctest Kore.Timestamp

  describe "datetime/x" do
    test "date stamp on today" do
      today = NaiveDateTime.local_now() |> Date.to_iso8601()
      naive = "#{today} 00:00:00"
      assert Timestamp.datetime(:today) == NaiveDateTime.from_iso8601!(naive)
    end

    test "give a date string" do
      assert Timestamp.datetime("2021-09-21") == ~N[2021-09-21 00:00:00]
    end

    test "give a utc string" do
      assert Timestamp.datetime("2021-09-21T00:00:00+00:00") == ~N[2021-09-21 00:00:00]
      assert Timestamp.datetime("2021-09-21T10:11:12+00:00") == ~N[2021-09-21 10:11:12]
    end

    test "utc without offset" do
      assert Timestamp.datetime("2022-09-21T00:00:00") == ~N[2022-09-21 00:00:00]
      assert Timestamp.datetime("2022-09-21T10:11:12") == ~N[2022-09-21 10:11:12]
    end

    test "today" do
      assert Timestamp.datetime(:today) == Timestamp.date(:today)
    end

    test "now" do
      assert Timestamp.datetime(:now) != Timestamp.date(:today)
      assert Timestamp.datetime(:now) == NaiveDateTime.local_now()
    end

    test "allow an day offset (day)" do
      assert Timestamp.datetime("2021-09-21", 1) == ~N[2021-09-22 00:00:00]
      assert Timestamp.datetime("2021-09-21", -1) == ~N[2021-09-20 00:00:00]
      assert Timestamp.datetime("2021-09-30", 1) == ~N[2021-10-01 00:00:00]

      tomorrow = Timestamp.datetime(:today) |> NaiveDateTime.add(1 * 60 * 60 * 24, :second)
      yesterday = Timestamp.datetime(:today) |> NaiveDateTime.add(-1 * 60 * 60 * 24, :second)
      assert Timestamp.date(:today, 1) == tomorrow
      assert Timestamp.date(:today, -1) == yesterday
    end

    test "allow a day offset (datetime)" do
      assert Timestamp.datetime("2021-09-21T00:00:00+00:00", 1) == ~N[2021-09-22 00:00:00]
      assert Timestamp.datetime("2021-09-21T10:11:12+00:00", 1) == ~N[2021-09-22 10:11:12]
    end

    test "allow an hour offset (day)" do
      assert Timestamp.datetime("2021-09-21", 1, 10) == ~N[2021-09-22 10:00:00]
      assert Timestamp.datetime("2021-09-21", -1, -10) == ~N[2021-09-19 14:00:00]
      assert Timestamp.datetime("2021-09-30", 1, 10) == ~N[2021-10-01 10:00:00]
    end

    test "allow a minute offset (day)" do
      assert Timestamp.datetime("2021-09-21", 1, 10, 3) == ~N[2021-09-22 10:03:00]
      assert Timestamp.datetime("2021-09-21", -1, -10, -3) == ~N[2021-09-19 13:57:00]
      assert Timestamp.datetime("2021-09-30", 1, 10, 3) == ~N[2021-10-01 10:03:00]
    end

    test "allow an hour offset (datetime)" do
      assert Timestamp.datetime("2021-09-21T00:00:00+00:00", 0, 10) == ~N[2021-09-21 10:00:00]
      assert Timestamp.datetime("2021-09-21T10:11:12+00:00", 1, 2) == ~N[2021-09-22 12:11:12]
    end

    test "allow a minute offset (datetime)" do
      assert Timestamp.datetime("2021-09-21T00:00:00+00:00", 0, 0, 5) == ~N[2021-09-21 00:05:00]
      assert Timestamp.datetime("2021-09-21T10:11:12+00:00", 1, 2, 5) == ~N[2021-09-22 12:16:12]
    end

    test "handle ~N" do
      assert Timestamp.datetime(~N[2021-09-21 10:00:00]) == ~N[2021-09-21 10:00:00]
      assert Timestamp.date(~N[2021-09-21 10:00:00]) == ~N[2021-09-21 00:00:00]

      assert Timestamp.datetime(~N[2021-09-21 10:00:00], 1, 2) == ~N[2021-09-22 12:00:00]
      assert Timestamp.date(~N[2021-09-21 10:00:00], 1) == ~N[2021-09-22 00:00:00]
    end

    test "handle ~D" do
      assert Timestamp.datetime(~D[2021-09-21]) == ~N[2021-09-21 00:00:00]
      assert Timestamp.date(~D[2021-09-21]) == ~N[2021-09-21 00:00:00]

      assert Timestamp.datetime(~D[2021-09-21], 1, 12) == ~N[2021-09-22 12:00:00]
      assert Timestamp.date(~D[2021-09-21], 1) == ~N[2021-09-22 00:00:00]
    end
  end

  describe "date/x" do
    test "date stamp on today" do
      today = NaiveDateTime.local_now() |> Date.to_iso8601()
      naive = "#{today} 00:00:00"
      assert Timestamp.date(:today) == NaiveDateTime.from_iso8601!(naive)
    end

    test "give a date string" do
      assert Timestamp.date("2021-09-21") == ~N[2021-09-21 00:00:00]
    end

    test "give a utc string" do
      assert Timestamp.date("2021-09-21T00:00:00+00:00") == ~N[2021-09-21 00:00:00]
    end

    test "utc without offset" do
      assert Timestamp.date("2022-09-21T00:00:00") == ~N[2022-09-21 00:00:00]
    end

    test "allow an offset" do
      assert Timestamp.date("2021-09-21", 1) == ~N[2021-09-22 00:00:00]
      assert Timestamp.date("2021-09-21", -1) == ~N[2021-09-20 00:00:00]
      assert Timestamp.date("2021-09-30", 1) == ~N[2021-10-01 00:00:00]
      assert Timestamp.date("2021-09-21T00:00:00+00:00", 1) == ~N[2021-09-22 00:00:00]

      tomorrow = Timestamp.date(:today) |> NaiveDateTime.add(1 * 60 * 60 * 24, :second)
      yesterday = Timestamp.date(:today) |> NaiveDateTime.add(-1 * 60 * 60 * 24, :second)
      assert Timestamp.date(:today, 1) == tomorrow
      assert Timestamp.date(:today, -1) == yesterday
    end

    test "allow :day_of_week" do
      assert Timestamp.date("2024-06-10", :tuesday) == ~N[2024-06-11 00:00:00]
      assert Timestamp.date("2024-06-10", :wednesday) == ~N[2024-06-12 00:00:00]
      assert Timestamp.date("2024-06-10", :thursday) == ~N[2024-06-13 00:00:00]
      assert Timestamp.date("2024-06-10", :friday) == ~N[2024-06-14 00:00:00]
      assert Timestamp.date("2024-06-10", :saturday) == ~N[2024-06-15 00:00:00]
      assert Timestamp.date("2024-06-10", :sunday) == ~N[2024-06-16 00:00:00]
      assert Timestamp.date("2024-06-10", :monday) == ~N[2024-06-17 00:00:00]
    end
  end

  describe "datetimeutc/x" do
    test "utc only db" do
      Calendar.put_time_zone_database(Calendar.UTCOnlyTimeZoneDatabase)
      assert Timestamp.datetimeutc(~N[2021-09-22 00:00:00], "EST") == ~U[2021-09-22 00:00:00Z]
    end

    test "unknown timezone" do
      Calendar.put_time_zone_database(TimeZoneInfo.TimeZoneDatabase)
      assert Timestamp.datetimeutc(~N[2021-09-22 00:00:00], "GOOP") == ~U[2021-09-22 00:00:00Z]
    end

    test "fully qualified UTC" do
      assert Timestamp.datetimeutc("2024-09-22T13:44:48Z") == ~U[2024-09-22 13:44:48Z]
      assert Timestamp.datetimeutc(nil) == nil
    end

    test "known timezone" do
      Calendar.put_time_zone_database(TimeZoneInfo.TimeZoneDatabase)

      assert Timestamp.datetimeutc(~N[2021-09-22 00:00:00], "MST") ==
               ~U[2021-09-22 07:00:00Z]

      assert Timestamp.datetimeutc(~N[2021-09-22 00:00:00], "EST") ==
               ~U[2021-09-22 05:00:00Z]
    end

    test "accept strings" do
      Calendar.put_time_zone_database(TimeZoneInfo.TimeZoneDatabase)

      assert Timestamp.datetimeutc("2021-09-22 00:00:00", "MST") ==
               ~U[2021-09-22 07:00:00Z]

      assert Timestamp.datetimeutc("2021-09-22 00:00:00", "EST") ==
               ~U[2021-09-22 05:00:00Z]
    end

    test "accept offsets" do
      Calendar.put_time_zone_database(TimeZoneInfo.TimeZoneDatabase)

      assert Timestamp.datetimeutc({"2021-09-22 00:00:00", 2}, "MST") ==
               ~U[2021-09-24 07:00:00Z]
    end

    test "accept day of week offsets" do
      Calendar.put_time_zone_database(TimeZoneInfo.TimeZoneDatabase)

      assert Timestamp.datetimeutc({"2024-06-10 00:00:00", :tuesday}, "MST") ==
               ~U[2024-06-11 07:00:00Z]
    end
  end

  describe "datetimegmt/x" do
    test "utc only db" do
      Calendar.put_time_zone_database(Calendar.UTCOnlyTimeZoneDatabase)

      assert Timestamp.datetimegmt(~N[2021-09-22 00:00:00], "EST") ==
               "2021-09-22T12:00:00 GMT+00:00"
    end

    test "unknown timezone" do
      Calendar.put_time_zone_database(TimeZoneInfo.TimeZoneDatabase)

      assert Timestamp.datetimegmt(~N[2021-09-22 00:00:00], "GOOP") ==
               "2021-09-22T12:00:00 GMT+00:00"
    end

    test "known timezone" do
      Calendar.put_time_zone_database(TimeZoneInfo.TimeZoneDatabase)

      assert Timestamp.datetimegmt(~N[2021-09-22 00:00:00], "MST") ==
               "2021-09-22T07:00:00 GMT+00:00"

      assert Timestamp.datetimegmt(~N[2021-09-22 00:00:00], "EST") ==
               "2021-09-22T05:00:00 GMT+00:00"
    end

    test "accept strings" do
      Calendar.put_time_zone_database(TimeZoneInfo.TimeZoneDatabase)

      assert Timestamp.datetimegmt("2021-09-22 00:00:00", "MST") ==
               "2021-09-22T07:00:00 GMT+00:00"

      assert Timestamp.datetimegmt("2021-09-22 00:00:00", "EST") ==
               "2021-09-22T05:00:00 GMT+00:00"
    end

    test "accept offset" do
      Calendar.put_time_zone_database(TimeZoneInfo.TimeZoneDatabase)

      assert Timestamp.datetimegmt({"2021-09-22 00:00:00", 2}, "MST") ==
               "2021-09-24T07:00:00 GMT+00:00"
    end
  end

  describe "day/x" do
    test "day stamp on today" do
      {:ok, today} = NaiveDateTime.local_now() |> Date.to_iso8601() |> Date.from_iso8601()
      assert Timestamp.day(:today) == today
    end

    test "give a day string" do
      assert Timestamp.day("2021-09-21") == ~D[2021-09-21]
    end

    test "give a utc string" do
      assert Timestamp.day("2021-09-21T00:00:00+00:00") == ~D[2021-09-21]
    end

    test "utc without offset" do
      assert Timestamp.day("2022-09-21T00:00:00") == ~D[2022-09-21]
    end

    test "allow an offset" do
      assert Timestamp.day("2021-09-21", 1) == ~D[2021-09-22]
      assert Timestamp.day("2021-09-21", -1) == ~D[2021-09-20]
      assert Timestamp.day("2021-09-30", 1) == ~D[2021-10-01]
      assert Timestamp.day("2021-09-21T00:00:00+00:00", 1) == ~D[2021-09-22]
    end
  end

  describe "same?/3" do
    @a Timestamp.date("2021-09-21T01:02:03+00:00")
    @same_second Timestamp.date("2021-09-21T01:02:03+00:00")
    @within_minute Timestamp.date("2021-09-21T01:02:04+00:00")
    # @within_hour Timestamp.date("2021-09-21T01:03:04+00:00")
    # @same_day Timestamp.date("2021-09-21T02:02:03+00:00")
    # @within_day Timestamp.date("2021-09-22T23:02:03+00:00")
    # @b Timestamp.date("2021-09-22T01:02:04+00:00")

    test "~N to the second" do
      assert_same(@a, @same_second, [:second, :minute, :hour, :day], [])
    end

    test "~N to the minute" do
      assert_same(@a, @within_minute, [:minute, :hour, :day], [:second])
    end

    test "~U to the second" do
      {:ok, a} = DateTime.from_naive(@a, "Etc/UTC")
      {:ok, same_second} = DateTime.from_naive(@same_second, "Etc/UTC")
      assert_same(a, same_second, [:second, :minute, :hour, :day], [])
    end

    test "~U to the minute" do
      {:ok, a} = DateTime.from_naive(@a, "Etc/UTC")
      {:ok, within_minute} = DateTime.from_naive(@within_minute, "Etc/UTC")
      assert_same(a, within_minute, [:minute, :hour, :day], [:second])
    end
  end

  def assert_same(ts1, ts2, sames, not_sames) do
    for precision <- sames do
      assert Timestamp.same?(ts1, ts2, precision)
    end

    for precision <- not_sames do
      refute Timestamp.same?(ts1, ts2, precision)
    end
  end
end
