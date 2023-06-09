defmodule Moria.Users do
  @moduledoc """
  Context module for Users
  """

  alias Moria.Users.User
  alias Moria.Repo

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)
  def get_user(id), do: Repo.get(User, id)

  def fetch_user(id) do
    get_user(id)
    |> Repo.normalize_one_result()
  end

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
