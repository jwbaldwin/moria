defmodule Moria.Time do
  def get_last_week_timings() do
    this_time_last_week = Timex.shift(Timex.now(), weeks: -1)

    %{
      start: Timex.beginning_of_week(this_time_last_week),
      end: Timex.end_of_week(this_time_last_week)
    }
  end
end
