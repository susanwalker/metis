defmodule MetisWeb.AuthController do
  use MetisWeb, :controller

  @ueberauth_plug Application.compile_env!(:metis, :ueberauth_plug)

  plug @ueberauth_plug

  def sign_in(conn, _params) do
    render(conn, "sign_in.html", conn: conn)
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> clear_session()
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: %{info: user_info}}} = conn, _params) do
    conn
    |> put_flash(:info, "Successfully logged in: #{user_info.nickname}")
    |> put_session(:current_user_info, user_info)
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end
end
