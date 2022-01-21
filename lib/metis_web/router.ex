defmodule MetisWeb.Router do
  use MetisWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {MetisWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :ensure_signed_in do
    plug :ensure_auth
  end

  scope "/", MetisWeb do
    pipe_through [:browser, :ensure_signed_in]

    get "/", PageController, :index
  end

  scope "/auth", MetisWeb do
    pipe_through :browser

    get "/sign-in", AuthController, :sign_in
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end

  defp ensure_auth(conn, _params) do
    if signed_in?(conn) do
      conn
    else
      conn
      |> put_flash(:error, "Please Sign-in")
      |> redirect(to: "/auth/sign-in")
      |> halt()
    end
  end

  defp signed_in?(conn) do
    get_session(conn, :current_user_info) != nil
  end
end
