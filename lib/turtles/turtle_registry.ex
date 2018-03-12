defmodule Turtles.TurtleRegistry do
  use GenServer
  @name __MODULE__
  @timeout :infinity

  @spec start_link() :: GenServer.on_start()
  def start_link() do
    GenServer.start_link(@name, [], name: @name)
  end

  @spec init(args :: term()) :: {:ok, state :: map()}
  def init(_args) do
    {:ok, %{next_id: 0, turtles: %{}}}
  end

  @spec generate_id() :: non_neg_integer()
  def generate_id() do
    GenServer.call(@name, :generate_id, @timeout)
  end

  @spec map_id_to_pid(id :: non_neg_integer(), pid :: pid()) :: :ok
  def map_id_to_pid(id, pid) do
    GenServer.call(@name, {:map_id_to_pid, id, pid}, @timeout)
  end

  def get_pid(id) do
    GenServer.call(@name, {:get_pid, id}, @timeout)
  end

  def handle_call({:get_pid, id}, _from, %{turtles: turtles} = state) do
    result =
      case Map.get(turtles, id) do
        nil -> {:error, :not_found}
        pid -> {:ok, pid}
      end

    {:reply, result, state}
  end

  def handle_call(:generate_id, _from, %{next_id: id} = state) do
    {:reply, id, %{state | next_id: id + 1}}
  end

  def handle_call({:map_id_to_pid, id, pid}, _from, %{turtles: turtles} = state) do
    {:reply, :ok, %{state | turtles: Map.put(turtles, id, pid)}}
  end
end
