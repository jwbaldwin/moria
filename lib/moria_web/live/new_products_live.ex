defmodule MoriaWeb.NewProductsLive do
  use MoriaWeb, :live_view

  alias Moria.Insights.Handlers.Brief

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      New products
    </.header>

    <.table id="products" rows={@products}>
      <:col :let={p} label="Product">
        <%= p.title %>
      </:col>
      <:col :let={p} label="Status">
        <%= p.status %>
      </:col>
      <:col :let={p} label="Vendor">
        <%= p.vendor %>
      </:col>
      <:col :let={p} label="Published at">
        <%= Timex.format!(p.published_at, "{Mfull} {D}, {YYYY}") %>
      </:col>
    </.table>

    <.back navigate={~p"/"}>Back to brief</.back>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign_brief(socket)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  defp assign_brief(socket) do
    with {:ok, brief} <- Brief.weekly_brief(socket.assigns.shop) do
      assign(socket, :products, brief.new_products)
    end
  end
end
