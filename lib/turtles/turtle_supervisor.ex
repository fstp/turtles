defmodule Turtles.TurtleSupervisor do
  use Supervisor
  @name __MODULE__

  @spec start_link() :: Supervisor.on_start()
  def start_link() do
    Supervisor.start_link(@name, [], name: @name)
  end

  def init(_args) do
    # TODO: Remove use of deprected supervisor spec and move to the new Elixir 1.6
    # way of doing it.
    import Supervisor.Spec, warn: false

    children = [
      worker(Turtles.Turtle, [])
    ]

    Supervisor.init(children, strategy: :simple_one_for_one)
  end

  @spec start_turtle(id :: non_neg_integer()) :: result
        when result: Supervisor.on_start_child()
  def start_turtle(id) do
    Supervisor.start_child(@name, [id])
  end
end
