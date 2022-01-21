defmodule MetisWeb.PageControllerTest do
  use MetisWeb.ConnCase

  describe "GET /" do
    test "200 (success) if user signed in", %{conn_with_auth: conn} do
      conn = get(conn, "/")
      assert conn.status == 200
    end

    test "302 (redirect) if user not signed in", %{conn_without_auth: conn} do
      conn = get(conn, "/")
      assert conn.status == 302

      assert html_response(conn, 302) =~ "href=\"/auth/sign-in\">redirected"
    end
  end
end
