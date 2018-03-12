defmodule Turtles.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  use Application

  @spec start(type :: Application.start_type(), args :: term()) ::
          {:ok, pid()}
          | {:ok, pid(), state :: term()}
          | {:error, reason :: term()}
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Turtles.Endpoint, []),
      worker(Turtles.TurtleRegistry, []),
      supervisor(Turtles.TurtleSupervisor, []),
      worker(Turtles.TurtleSim, [])
    ]

    opts = [strategy: :rest_for_one, name: Turtles.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
