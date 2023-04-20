defmodule Moria.Users do
  @moduledoc """
  Context module for Users
  """

  alias Moria.Users.User
  alias Moria.Repo

  @doc """
  Creates a user. Plug.Pow.create(conn, params) will do the same
  but returns a connection.
  """
  def create(params) do
    %User{}
    |> User.changeset(params)
    |> Repo.insert()
  end
end
