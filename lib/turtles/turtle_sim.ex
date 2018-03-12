defmodule Turtles.TurtleSim do
  use GenServer
  @name __MODULE__
  @timeout :infinity

  def start_link() do
    GenServer.start_link(@name, [], name: @name)
  end

  def init(_args) do
    {:ok, %{turtles: %{}}}
  end

  def create_turtle() do
    GenServer.call(@name, :create_turtle, @timeout)
  end

  def handle_call(:create_turtle, _from, state) do
    %HTTPotion.Response{body: body} = HTTPotion.get!("http://localhost:4000/init")
    turtle_id = String.to_integer(body)
    {:reply, :ok, %{state | turtles: Map.put(state.turtles, turtle_id, %{})}}
  end
end
