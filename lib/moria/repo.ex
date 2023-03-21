defmodule Moria.Repo do
  use Ecto.Repo,
    otp_app: :moria,
    adapter: Ecto.Adapters.Postgres
end
