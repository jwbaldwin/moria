defmodule MoriaWeb.PolicyController do
  use MoriaWeb, :controller

  def privacy(conn, _params) do
    render(conn, :privacy)
  end
end
