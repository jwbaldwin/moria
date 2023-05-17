defmodule MoriaWeb.HealthController do
  use MoriaWeb, :controller

  def index(conn, _) do
    render(conn, :"200")
  end
end
