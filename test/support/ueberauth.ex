defmodule MetisWeb.Test.Ueberauth do
  @moduledoc """
  Test ueberauth to easily test ueberauth
  """

  def init(opts), do: opts

  def call(conn, _params) do
    route_prefix = Path.join(["/" | conn.script_name])
    route_path = Path.relative_to(conn.request_path, route_prefix)

    # Run Ueberauth only for `request`, not `callback`
    if route_path == "auth/github" do
      Plug.run(
        conn,
        [{Ueberauth, []}]
      )
    else
      conn
    end
  end
end
