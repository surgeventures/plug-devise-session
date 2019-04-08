defmodule PlugDeviseSession.Helpers do
  @moduledoc """
  Helpers that assist in working with session fetched via `PlugDeviseSession` plug.
  """

  @type id :: integer
  @type salt :: String.t()
  @type scope :: atom | String.t()

  alias Plug.Conn

  @doc """
  Removes user auth data, optionally from a specified scope.
  """
  @spec delete_user_auth_data(Plug.Conn.t(), scope) :: Plug.Conn.t()
  def delete_user_auth_data(conn, scope \\ :user) do
    Conn.delete_session(conn, "warden.user.#{scope}.key")
  end

  @doc """
  Returns currently logged-in user's identifier, optionally in specified scope.
  """
  @deprecated "Use get_user_auth_data/2 instead"
  @spec get_user_id(Plug.Conn.t(), scope) :: id | nil
  def get_user_id(conn, scope \\ :user) do
    case Conn.get_session(conn, "warden.user.#{scope}.key") do
      [[id], _] when is_integer(id) ->
        id

      [_, [id], _] when is_integer(id) ->
        id

      _ ->
        nil
    end
  end

  @doc """
  Returns currently logged-in user's id and auth salt, optionally in specified scope.
  """
  @spec get_user_auth_data(Plug.Conn.t(), scope) :: {id, salt} | nil
  def get_user_auth_data(conn, scope \\ :user) do
    case Conn.get_session(conn, "warden.user.#{scope}.key") do
      [[id], auth_salt] when is_integer(id) ->
        {id, auth_salt}

      [_, [id], auth_salt] when is_integer(id) ->
        {id, auth_salt}

      _ ->
        nil
    end
  end

  @doc """
  Puts user's id and auth salt, optionally in specified scope.
  """
  @spec put_user_auth_data(Plug.Conn.t(), id, salt, scope) :: Plug.Conn.t()
  def put_user_auth_data(conn, id, auth_salt, scope \\ :user) do
    Conn.put_session(conn, "warden.user.#{scope}.key", [[id], auth_salt])
  end

  @doc """
  Puts session id.
  """
  @spec put_session_id(Plug.Conn.t(), integer) :: Plug.Conn.t()
  def put_session_id(conn, length) do
    Conn.put_session(conn, "session_id", random_string(length))
  end

  defp random_string(length) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end
