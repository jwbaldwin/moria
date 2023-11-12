defmodule MoriaWeb.PageController do
  use MoriaWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
