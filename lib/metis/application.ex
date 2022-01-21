defmodule Metis.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      MetisWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Metis.PubSub},
      # Start the Endpoint (http/https)
      MetisWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Metis.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    MetisWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
