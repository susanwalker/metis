defmodule MetisWeb.DashboardLive do
  use MetisWeb, :live_view

  @frequency 100

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:author_commits, %{})
      |> assign(:error, nil)
      |> assign(:params, %{})

    {:ok, socket}
  end

  def handle_event("fetch_commits", %{"fetch_commits" => params}, socket) do
    case list_commits(params) do
      {:ok, commits} ->
        date = get_earliest_commit_date(commits)
        author_commits = fetch_author_commits(commits, date)
        max_commits = get_max_commits(commits)

        socket =
          socket
          |> assign(:commits, commits)
          |> assign(:author_commits, author_commits)
          |> assign(:error, nil)
          |> assign(:date, date)
          |> assign(:ended, false)
          |> assign(:params, params)
          |> assign(:max_commits, max_commits)

        Process.send_after(self(), :update, @frequency)

        {:noreply, socket}

      {:error, error} ->
        socket =
          socket
          |> assign(:author_commits, %{})
          |> assign(:error, error)
          |> assign(:params, params)

        {:noreply, socket}
    end
  end

  def handle_info(:update, socket) do
    current_date = socket.assigns.date
    commits = socket.assigns.commits

    date = Date.add(current_date, 1)

    author_commits = fetch_author_commits(commits, date)

    ended = Date.diff(get_last_commit_date(commits), date) <= 0

    socket =
      socket
      |> assign(:commits, commits)
      |> assign(:author_commits, author_commits)
      |> assign(:error, nil)
      |> assign(:date, date)
      |> assign(:ended, ended)

    unless ended do
      Process.send_after(self(), :update, @frequency)
    end

    {:noreply, socket}
  end

  defp fetch_author_commits(commits, date) do
    commits
    |> Enum.filter(fn commit ->
      commit_date = date_from_commit(commit)
      Date.diff(commit_date, date) <= 0
    end)
    |> Enum.group_by(fn commit -> {commit["author"]["login"], commit["author"]["avatar_url"]} end)
    |> Enum.reject(fn {{author_name, _}, _} -> is_nil(author_name) or author_name == "" end)
    |> Enum.map(fn {author, author_commits} -> {author, length(author_commits)} end)
    |> Enum.sort_by(fn {_, length} -> length end, :desc)
  end

  defp get_max_commits(commits) do
    commits
    |> Enum.group_by(fn commit -> {commit["author"]["login"], commit["author"]["avatar_url"]} end)
    |> Enum.map(fn {author, author_commits} -> {author, length(author_commits)} end)
    |> Enum.max_by(fn {_, length} -> length end)
    |> elem(1)
  end

  defp get_earliest_commit_date(commits) do
    commit = Enum.min_by(commits, &date_from_commit/1, Date)
    date_from_commit(commit)
  end

  defp get_last_commit_date(commits) do
    commit = Enum.max_by(commits, &date_from_commit/1, Date)
    date_from_commit(commit)
  end

  defp list_commits(%{"owner" => owner, "repo" => repo, "personal_access_token" => pat}) do
    pat = resolve_pat(pat)
    Metis.GitHubAPI.list_commits(owner, repo, pat)
  end

  defp resolve_pat(pat), do: (pat == "" && nil) || pat

  defp date_from_commit(commit) do
    {:ok, datetime, _offset} = DateTime.from_iso8601(commit["commit"]["author"]["date"])
    DateTime.to_date(datetime)
  end
end
