defmodule MoriaWeb.ShopifyInfo do
  use MoriaWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  @doc """
  Handles mounting of the Shopify shop in LiveViews.
  """
  def session(conn) do
    %{"shop" => Shopifex.Plug.current_shop(conn)}
  end

  def on_mount(:assign_shop, _params, session, socket) do
    {:cont, Phoenix.Component.assign(socket, :shop, session["shop"])}
  end
end
