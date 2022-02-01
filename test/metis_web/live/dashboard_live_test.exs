defmodule MetisWeb.DashboardLiveTest do
  use MetisWeb.ConnCase
  import Phoenix.LiveViewTest
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    HTTPoison.start()
    :ok
  end

  describe "mount/2" do
    test "renders a form and no data", %{conn: conn} do
      conn = get(conn, "/")
      assert html_response(conn, 200) =~ "<div id=\"githubForm\">"
      {:ok, view, html} = live(conn)

      assert view.module == MetisWeb.DashboardLive

      assert html =~ "No commits to display"
    end
  end

  describe "handle_event/3 (event = fetch_commits)" do
    test "gets data from GitHub and renders it", %{conn: conn} do
      use_cassette "list_commits/public_repo/success" do
        conn = get(conn, "/")
        {:ok, view, _html} = live(conn)

        html =
          view
          |> element("form")
          |> render_submit(%{
            fetch_commits: %{
              owner: "susanwalker",
              repo: "metis",
              personal_access_token: ""
            }
          })

        assert html =~ "Date: 2022-01-21"

        assert html =~ "(susanwalker) 10"

        :timer.sleep(100)

        assert render(view) =~ "Date: 2022-01-22"
      end
    end

    test "renders error if error in fetching commits", %{conn: conn} do
      use_cassette "list_commits/private_repo/failure" do
        conn = get(conn, "/")
        {:ok, view, _html} = live(conn)

        html =
          view
          |> element("form")
          |> render_submit(%{
            fetch_commits: %{
              owner: "susanwalker",
              repo: "pericles",
              personal_access_token: ""
            }
          })

        assert html =~ "Error in fetching commits: Not Found"
      end
    end
  end
end