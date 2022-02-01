defmodule Metis.GitHubAPI do
  @moduledoc """
  Responsible for fetching commit data from GitHub
  """

  @doc """
  Returns a list of commits for the given repo and optional auth_token
  """
  def list_commits(owner, repo, auth_token \\ nil) do
    case do_list_commits(owner, repo, auth_token) do
      {200, commits, _response} -> {:ok, commits}
      {status, error, _response} -> {:error, error}
    end
  end

  defp do_list_commits(owner, repo, auth_token) do
    auth_token
    |> new_client()
    |> Tentacat.Commits.list(owner, repo)
  end

  defp new_client(nil), do: Tentacat.Client.new()
  defp new_client(auth_token), do: Tentacat.Client.new(%{access_token: auth_token})
end
