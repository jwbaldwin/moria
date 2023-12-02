defmodule MoriaWeb.HomeLive.Index do
  use MoriaWeb, :live_view

  alias Moria.Insights.Handlers.Brief
  alias Moria.Time

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    cw = Map.get(params, "cw", "-1")

    {:noreply,
     socket
     |> assign(token: params["token"])
     |> assign(current_week: String.to_integer(cw))
     |> assign_range()
     |> assign_brief()}
  end

  @impl true
  def handle_event("next", _unsigned_params, socket) do
    current_week = socket.assigns.current_week + 1

    {:noreply,
     push_patch(socket, to: "/?token=#{socket.assigns.token}&cw=#{current_week}", replace: true)}
  end

  @impl true
  def handle_event("previous", _unsigned_params, socket) do
    current_week = socket.assigns.current_week - 1

    {:noreply,
     push_patch(socket, to: "/?token=#{socket.assigns.token}&cw=#{current_week}", replace: true)}
  end

  @impl true
  def handle_event("sync", _unsigned_params, socket) do
    Moria.Workers.EnqueueShopifySyncWorkers.call(socket.assigns.shop)

    {:noreply,
     put_flash(socket, :info, "Syncing shop data for #{translate_url(socket.assigns.shop.url)}")}
  end

  defp assign_range(socket) do
    assign(socket, :range, Time.get_last_week_timings(socket.assigns.current_week))
  end

  defp assign_brief(socket) do
    with {:ok, brief} <- Brief.weekly_brief(socket.assigns.shop, socket.assigns.range) do
      assign(socket, :brief, brief)
    end
  end

  @doc """
  Turns a shopify url into a shop name
  """
  def translate_url(shop_url) do
    shop_url
    |> String.split(".")
    |> List.first()
    |> String.split("-")
    |> Enum.map_join(" ", &String.capitalize/1)
  end
end
