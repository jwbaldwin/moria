defmodule MoriaWeb.HomeLive.Index do
  use MoriaWeb, :live_view

  alias Moria.Insights.Handlers.Brief
  alias Moria.Time

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_range()
     |> assign_brief()}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  defp assign_range(socket) do
    range = Time.get_last_week_timings()

    assign(socket, :range, %{
      start: Timex.format!(range.start, "{Mfull} {D}, {YYYY}"),
      end: Timex.format!(range.end, "{Mfull} {D}, {YYYY}")
    })
  end

  defp assign_brief(socket) do
    with {:ok, brief} <- Brief.weekly_brief(socket.assigns.shop) do
      assign(socket, :brief, brief)
    end
  end
end
