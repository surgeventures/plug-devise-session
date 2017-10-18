defmodule PlugDeviseSessionTest do
  use ExUnit.Case
  use Plug.Test
  alias Plug.Conn
  alias PlugDeviseSession
  alias PlugDeviseSession.Helpers

  test "patches the config" do
    System.put_env("SESSION_COOKIE_DOMAIN", "my.domain.com")

    secret_key_base =
      1..64
      |> Enum.map(fn _ -> "x" end)
      |> Enum.join()

    System.put_env("SECRET_KEY_BASE", secret_key_base)

    opts = [store: :cookie,
            key: "_my_rails_project_session",
            domain: {:system, "SESSION_COOKIE_DOMAIN"}]

    setter_conn =
      :get
      |> conn("/foo")
      |> Map.put(:secret_key_base, {:system, "SECRET_KEY_BASE"})
      |> PlugDeviseSession.call(PlugDeviseSession.init(opts))
      |> Conn.fetch_session()
      |> Conn.put_session("warden.user.user.key", [[123], ""])
      |> Conn.put_session("warden.user.employee.key", ["", [456], ""])
      |> resp(200, "")
      |> send_resp()

    assert %{resp_cookies: %{
      "_my_rails_project_session" => %{
        domain: "my.domain.com",
        value: session_cookie
      }
    }} = setter_conn

    getter_conn =
      :get
      |> conn("/foo")
      |> Map.put(:secret_key_base, secret_key_base)
      |> put_req_cookie("_my_rails_project_session", session_cookie)
      |> PlugDeviseSession.call(PlugDeviseSession.init(opts))
      |> Conn.fetch_session()

    assert Helpers.get_user_id(getter_conn) == 123
    assert Helpers.get_user_id(getter_conn, :employee) == 456
  end
end
