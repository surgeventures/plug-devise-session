defmodule PlugDeviseSession.Rememberable do
  @moduledoc """
  Helps issuing and reading Devise's remember user cookie.

  Important module assumptions:

    * All `Plug.Conn` structures should have a valid `secret_key_base` set.
    * User authorization info is a three element tuple of the form: `{id, auth_key, timestamp}`.
    * Remember timestamps are required to be in the `Etc/UTC` time zone.

  """

  @type id :: integer
  @type auth_key :: String.t()
  @type timestamp :: DateTime.t()
  @type scope :: atom | String.t()
  @type user_auth_info :: {id, auth_key, timestamp}

  @type opts :: [
          key_digest: atom,
          key_iterations: integer,
          key_length: integer,
          serializer: module,
          signing_salt: binary
        ]

  alias Plug.Conn
  alias Plug.Crypto.KeyGenerator
  alias PlugRailsCookieSessionStore.MessageVerifier

  @default_opts [
    key_digest: :sha,
    key_iterations: 1000,
    key_length: 64,
    serializer: ExMarshal,
    signing_salt: "signed cookie"
  ]

  @doc """
  Sets a signed remember user cookie on the connection.

  ## Options

    * `:key_digest` - digest algorithm to use for deriving the signing key. Accepts any value supported by `Plug.Crypto.KeyGenerator.generate/3`, defaults to `:sha`.
    * `:key_iterations` - number of iterations for signing key derivation. Accepts any value supported by `Plug.Crypto.KeyGenerator.generate/3`, defaults to 1000.
    * `:key_length` - desired length of derived signing key. Accepts any value supported by `Plug.Crypto.KeyGenerator.generate/3`, defaults to 64.
    * `:serializer` - module used for cookie data serialization, defaults to `PlugDeviseSession.Marshal` which in turn uses `ExMarshal` (a Rails-compatible marshal module).
    * `:signing_salt` - salt used for signing key derivation. Should be set to the value used by Rails, defaults to "signed cookie".

  """
  @spec remember_user(Plug.Conn.t(), user_auth_info, scope, opts) :: Plug.Conn.t()
  def remember_user(conn, {id, auth_key, timestamp}, scope \\ :user, opts \\ []) do
    options = Keyword.merge(@default_opts, opts)
    serializer = Keyword.fetch!(options, :serializer)
    signing_key = generate_key(conn, options)

    cookie_value =
      [[id], auth_key, encode_timestamp(timestamp)]
      |> serializer.encode()
      |> MessageVerifier.sign(signing_key)
      |> URI.encode_www_form()

    Conn.put_resp_cookie(conn, "remember_#{scope}_token", cookie_value)
  end

  defp encode_timestamp(%DateTime{time_zone: "Etc/UTC", utc_offset: 0} = timestamp) do
    microseconds = DateTime.to_unix(timestamp, :microseconds)
    Float.to_string(microseconds / 1_000_000.0)
  end

  @doc """
  Recovers user authentication info from remember cookie.

  ## Options

  * `:key_digest` - digest algorithm to use for deriving the signing key. Accepts any value supported by `Plug.Crypto.KeyGenerator.generate/3`, defaults to `:sha`.
  * `:key_iterations` - number of iterations for signing key derivation. Accepts any value supported by `Plug.Crypto.KeyGenerator.generate/3`, defaults to 1000.
  * `:key_length` - desired length of derived signing key. Accepts any value supported by `Plug.Crypto.KeyGenerator.generate/3`, defaults to 64.
  * `:serializer` - module used for cookie data serialization, defaults to `PlugDeviseSession.Marshal` which in turn uses `ExMarshal` (a Rails-compatible marshal module).
  * `:signing_salt` - salt used for signing key derivation. Should be set to the value used by Rails, defaults to "signed cookie".

  """
  @spec recover_user(Plug.Conn.t(), scope, opts) :: {:ok, user_auth_info} | {:error, :unauthorized}
  def recover_user(conn, scope \\ :user, opts \\ []) do
    options = Keyword.merge(@default_opts, opts)
    serializer = Keyword.fetch!(options, :serializer)
    verification_key = generate_key(conn, options)

    with cookie_value when is_binary(cookie_value) <- conn.cookies["remember_#{scope}_token"],
         decoded_cookie_value <- URI.decode_www_form(cookie_value),
         {:ok, contents} <- MessageVerifier.verify(decoded_cookie_value, verification_key) do
      [[id], auth_key, timestamp] = serializer.decode(contents)
      {:ok, {id, auth_key, decode_timestamp(timestamp)}}
    else
      _ -> {:error, :unauthorized}
    end
  end

  defp decode_timestamp(timestamp) when is_binary(timestamp) do
    {seconds, ""} = Float.parse(timestamp)

    (seconds * 1_000_000)
    |> trunc()
    |> DateTime.from_unix!(:microseconds)
  end

  defp generate_key(%Plug.Conn{secret_key_base: secret_key_base}, opts) do
    signing_salt = Keyword.fetch!(opts, :signing_salt)

    key_options = [
      digest: Keyword.fetch!(opts, :key_digest),
      iterations: Keyword.fetch!(opts, :key_iterations),
      length: Keyword.fetch!(opts, :key_length)
    ]

    KeyGenerator.generate(secret_key_base, signing_salt, key_options)
  end
end
