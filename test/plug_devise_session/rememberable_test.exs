defmodule PlugDeviseSession.RememberableTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use Plug.Test
  alias PlugDeviseSession.Rememberable

  @secret_key_base "this is a super secret key"
  @user_id 5
  @user_auth_key "beginning of encrypted password"
  @user_timestamp %DateTime{
    year: 2018,
    month: 8,
    day: 3,
    hour: 11,
    minute: 22,
    second: 33,
    microsecond: {0, 0},
    utc_offset: 0,
    std_offset: 0,
    zone_abbr: "UTC",
    time_zone: "Etc/UTC"
  }
  @user_auth_data {@user_id, @user_auth_key, @user_timestamp}
  @reference_cookie_content "BAhbCFsGaQpJIiRiZWdpbm5pbmcgb2YgZW5jcnlwdGVkIHBhc3N3b3JkBjoGRVRJIhExNTMzMjk1MzUzLjAGOwBU"

  def patch_secret_key_base(conn, secret_key_base) do
    put_in(conn.secret_key_base, secret_key_base)
  end

  setup do
    conn = :post |> conn("/sign-in") |> patch_secret_key_base(@secret_key_base)
    {:ok, conn: conn}
  end

  describe "remember_user/4" do
    test "issues remember user cookie", %{conn: conn} do
      remember_conn =
        conn
        |> Rememberable.remember_user(@user_auth_data)
        |> fetch_cookies()

      cookie_value = remember_conn.cookies["remember_user_token"]
      [content, _digest] = String.split(cookie_value, "--")

      assert is_binary(cookie_value)
      assert content == @reference_cookie_content
    end

    test "respects scope parameter", %{conn: conn} do
      remember_conn =
        conn
        |> Rememberable.remember_user(@user_auth_data, :employee)
        |> fetch_cookies()

      assert is_binary(remember_conn.cookies["remember_employee_token"])
    end

    test "raises when timestamp is not in UTC", %{conn: conn} do
      cest_timestamp = %DateTime{
        @user_timestamp
        | time_zone: "Europe/Warsaw",
          utc_offset: 7_200,
          zone_abbr: "CEST"
      }

      assert_raise(FunctionClauseError, fn ->
        Rememberable.remember_user(conn, {@user_id, @user_auth_key, cest_timestamp})
      end)
    end
  end

  describe "recover_user/3" do
    test "recovers user auth data", %{conn: conn} do
      {:ok, {user_id, user_auth_key, user_timestamp}} =
        conn
        |> Rememberable.remember_user(@user_auth_data)
        |> fetch_cookies()
        |> Rememberable.recover_user()

      assert user_id == @user_id
      assert user_auth_key == @user_auth_key
      assert DateTime.compare(user_timestamp, @user_timestamp) == :eq
    end

    test "respects scope parameter", %{conn: conn} do
      {:ok, {user_id, user_auth_key, user_timestamp}} =
        conn
        |> Rememberable.remember_user(@user_auth_data, :employee)
        |> fetch_cookies()
        |> Rememberable.recover_user(:employee)

      assert user_id == @user_id
      assert user_auth_key == @user_auth_key
      assert DateTime.compare(user_timestamp, @user_timestamp) == :eq
    end

    test "returns unauthorized error when cookie not set", %{conn: conn} do
      assert {:error, :unauthorized} =
               conn
               |> fetch_cookies()
               |> Rememberable.recover_user()
    end

    test "returns unauthorized error when cookie signed with different secret", %{conn: conn} do
      assert {:error, :unauthorized} =
               conn
               |> patch_secret_key_base("some secret key base")
               |> Rememberable.remember_user(@user_auth_data)
               |> fetch_cookies()
               |> patch_secret_key_base("other secret key base")
               |> Rememberable.recover_user()
    end

    test "returns unauthorized error when cookie signed with different salt", %{conn: conn} do
      assert {:error, :unauthorized} =
               conn
               |> Rememberable.remember_user(@user_auth_data, :user, signing_salt: "some salt")
               |> fetch_cookies()
               |> Rememberable.recover_user(:user, signing_salt: "other salt")
    end
  end
end
