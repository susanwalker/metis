defmodule MetisWeb.AuthControllerTest do
  use MetisWeb.ConnCase

  describe "new/2" do
    test "renders login page" do
      conn = conn_without_auth()

      conn = get(conn, Routes.auth_path(conn, :sign_in))

      assert html_response(conn, 200) =~ "Sign-in"
    end
  end

  describe "delete/2" do
    test "logs the current user out" do
      conn = conn_with_auth()

      refute is_nil(Plug.Conn.get_session(conn)["current_user_info"])

      conn = delete(conn, Routes.auth_path(conn, :delete))

      assert is_nil(Plug.Conn.get_session(conn)["current_user_info"])

      assert html_response(conn, 302) =~ "href=\"/\">redirected"
    end
  end

  describe "request/2" do
    test "dispatches to the provider only if authorized (github)" do
      conn = conn_without_auth()

      conn = get(conn, Routes.auth_path(conn, :request, "github"))

      assert conn.status == 302
    end
  end

  describe "callback/2" do
    test "signs in and creates admin when ueberauth is successful" do
      user_deets = %{
        info: %{
          email: "some@email.com",
          nickname: "github_username",
          first_name: nil,
          last_name: nil,
          phone: nil
        }
      }

      conn =
        conn_without_auth()
        |> assign(:ueberauth_auth, user_deets)

      assert is_nil(Plug.Conn.get_session(conn)["current_user_info"])

      conn =
        get(
          conn,
          Routes.auth_path(conn, :callback, "github")
        )

      refute is_nil(Plug.Conn.get_session(conn)["current_user_info"])

      assert html_response(conn, 302) =~ "href=\"/\">redirected"
    end

    test "redirects with error when ueberauth fails" do
      conn =
        conn_without_auth()
        |> assign(:ueberauth_failure, :something)

      assert is_nil(Plug.Conn.get_session(conn)["current_user_info"])

      conn =
        get(
          conn,
          Routes.auth_path(conn, :callback, "github")
        )

      assert is_nil(Plug.Conn.get_session(conn)["current_user_info"])

      assert html_response(conn, 302) =~ "href=\"/\">redirected"
    end
  end
end
