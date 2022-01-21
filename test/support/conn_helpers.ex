defmodule MetisWeb.ConnHelpers do
  @moduledoc """
  Helpers to sign-in, auth conn
  """
  @default_opts [
    store: :cookie,
    key: "foobar",
    encryption_salt: "encrypted cookie salt",
    signing_salt: "signing salt",
    log: false
  ]
  @secret String.duplicate("abcdef0123456789", 8)
  @signing_opts Plug.Session.init(Keyword.put(@default_opts, :encrypt, false))

  def conn_without_auth do
    conn = Phoenix.ConnTest.build_conn()

    conn.secret_key_base
    |> put_in(@secret)
    |> Plug.Session.call(@signing_opts)
    |> Plug.Conn.fetch_session()
    |> Phoenix.Controller.fetch_flash()
    |> Plug.Conn.fetch_session()
  end

  def conn_with_auth do
    conn_without_auth() |> Plug.Conn.put_session(:current_user_info, :user_info)
  end
end
