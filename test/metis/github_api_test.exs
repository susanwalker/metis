defmodule Metis.GitHubAPITest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Metis.GitHubAPI

  setup_all do
    HTTPoison.start()
    :ok
  end

  describe "list_commits/3" do
    test "lists commits for a public repo without auth token" do
      use_cassette "list_commits/public_repo/success" do
        {:ok, commits} = GitHubAPI.list_commits("susanwalker", "metis")
        assert length(commits) == 12

        [commit | _tail] = commits

        assert commit["commit"]["author"]["name"] == "Susan Walker"
        assert commit["commit"]["author"]["email"] == "susanwalker8@gmail.com"
        assert commit["commit"]["author"]["date"] == "2022-02-01T00:05:10Z"
      end
    end

    test "lists commits for a private repo with auth token" do
      use_cassette "list_commits/private_repo/success" do
        {:ok, commits} = GitHubAPI.list_commits("susanwalker", "pericles", "pat")
        assert length(commits) == 26

        [commit | _tail] = commits

        assert commit["commit"]["author"]["name"] == "Susan Walker"
        assert commit["commit"]["author"]["email"] == "susanwalker8@gmail.com"
        assert commit["commit"]["author"]["date"] == "2022-01-16T03:36:42Z"
      end
    end

    test "does not list commits for a private repo without auth token" do
      use_cassette "list_commits/private_repo/failure" do
        {status, body} = GitHubAPI.list_commits("susanwalker", "pericles")

        assert status == :error
        assert body["message"] == "Not Found"
      end
    end
  end
end
