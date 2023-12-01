defmodule MoriaWeb.TopCustomersLive do
  use MoriaWeb, :live_view

  alias Moria.Insights.Handlers.Brief
  alias Moria.Time

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Top customers
    </.header>

    <.table id="customers" rows={@customers}>
      <:col :let={c} label="Customer Name">
        <%= c.customer.first_name %> <%= c.customer.last_name %>
      </:col>
      <:col :let={c} label="Email">
        <%= c.customer.email %>
      </:col>
      <:col :let={c} label="Phone number">
        <%= c.customer.phone %>
      </:col>
      <:col :let={c} label="Total spent last week">
        <%= Moria.Money.format(c.total_spent) %>
      </:col>
    </.table>

    <.back navigate={~p"/?token=#{@token}&cw=#{@current_week}"}>Back to brief</.back>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(token: params["token"])
     |> assign(current_week: String.to_integer(params["cw"]))
     |> assign_brief()}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  defp assign_brief(socket) do
    with {:ok, brief} <-
           Brief.weekly_brief(
             socket.assigns.shop,
             Time.get_last_week_timings(socket.assigns.current_week)
           ) do
      assign(socket, :customers, brief.top_customers.top_customers)
    end
  end
end
