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

  scope "/", MetisWeb do
    pipe_through :browser

    get "/", PageController, :index
  end
end
