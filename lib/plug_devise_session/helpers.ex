defmodule PlugDeviseSession.Helpers do
  @moduledoc """
  Helpers that assist in working with session fetched via `PlugDeviseSession` plug.
  """

  alias Plug.Conn

  @doc """
  Removes user auth data, optionally from a specified scope.
  """
  def delete_user_auth_data(conn, scope \\ :user) do
    Conn.delete_session(conn, "warden.user.#{scope}.key")
  end

  @doc """
  Returns currently logged-in user's identifier, optionally in specified scope.
  """
  @deprecated "Use get_user_auth_data/2 instead"
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
  def put_user_auth_data(conn, id, auth_salt, scope \\ :user) do
    Conn.put_session(conn, "warden.user.#{scope}.key", [[id], auth_salt])
  end
end
