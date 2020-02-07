defmodule PlugDeviseSession do
  @moduledoc """
  Simple plug for sharing Devise session in Elixir.

  ## Usage

  Add the following to your application's endpoint (or replace an existing call to `Plug.Session`):

      plug PlugDeviseSession,
        key: "_my_rails_project_session"

  Here's a list of additional options:

  - `domain`: set it to `domain` provided in the `session_store()` call of your Ruby on Rails
    project

  - `extra`: lets specify arbitrary options that are added to cookie

  - `max_age`: desired validity of remember user cookie in seconds

  - `path`: send cookie only on matching URL path

  - `secure`: a secure cookie is only sent to the server over the HTTPS protocol

  - `serializer`: set it to `Poison` or other JSON serializer of choice if your Ruby on Rails
    project sets `cookies_serializer` to `:json` (default in Rails 4.1 and newer)

  - `signing_salt`: set it to the value of `encrypted_signed_cookie_salt` if your Ruby on Rails
     project sets it

  - `encryption_salt`: set it to the value of `encrypted_cookie_salt` if your Ruby on Rails project
    sets it

  - `signing_with_salt`: set it to `false` if your Ruby on Rails project is based on Rails 3.2 or
    older

  Remember to also set secret key base to match the one in your Rails project:

      config :my_project, MyProject.Web.Endpoint,
        secret_key_base: "secret..."

  In order to read the session, you must first fetch the session in your router pipeline:

      plug :fetch_session

  Finally, you can get the current user's identifier as follows:

      PlugDeviseSession.Helpers.get_user_id()

  """

  alias Confix
  alias Plug.Session
  alias PlugDeviseSession.Marshal

  @default_opts [
    store: PlugRailsCookieSessionStore,
    serializer: Marshal,
    encryption_salt: "encrypted cookie",
    signing_salt: "signed encrypted cookie",
    key_iterations: 1000,
    key_length: 64,
    key_digest: :sha
  ]

  def init(opts) do
    @default_opts
    |> Keyword.merge(opts)
    |> Session.init()
  end

  def call(conn, config) do
    conn
    |> patch_conn()
    |> Session.call(patch_config(config))
  end

  defp patch_conn(conn) do
    update_in(conn.secret_key_base, &Confix.parse/1)
  end

  defp patch_config(config) do
    config
    |> update_in([:cookie_opts, :domain], &Confix.parse/1)
    |> update_in([:cookie_opts, :extra], &Confix.parse/1)
    |> update_in([:cookie_opts, :max_age], &Confix.parse/1)
    |> update_in([:cookie_opts, :path], &Confix.parse/1)
    |> update_in([:cookie_opts, :secure], &Confix.parse/1)
    |> update_in([:key], &Confix.parse/1)
    |> update_in([:store_config, :encryption_salt], &Confix.parse/1)
    |> update_in([:store_config, :signing_salt], &Confix.parse/1)
  end
end
