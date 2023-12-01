defmodule Moria.Time do
  def get_last_week_timings(weeks_ago \\ -1) do
    this_time_last_week = Timex.shift(Timex.now(), weeks: weeks_ago)

    %{
      start: Timex.beginning_of_week(this_time_last_week),
      end: Timex.end_of_week(this_time_last_week)
    }
  end
end
