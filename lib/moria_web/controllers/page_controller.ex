defmodule MoriaWeb.PageController do
  use MoriaWeb, :controller

  def home(conn, _params) do
    IO.inspect(conn)
    render(conn, :home)
  end
end
