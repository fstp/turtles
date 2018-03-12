defmodule Turtles.Turtle do
  use GenServer
  require Logger
  @name __MODULE__
  @timeout :infinity
  # @idle_timeout 60_000

  @spec start_link(id :: non_neg_integer()) :: GenServer.on_start()
  def start_link(id) do
    GenServer.start_link(@name, %{id: id})
  end

  @spec init(state) :: {:ok, state} when state: map()
  def init(%{id: id} = state) do
    Turtles.TurtleRegistry.map_id_to_pid(id, self())
    {:ok, Map.put(state, :sm_stack, [create_sm("idle", state)])}
  end

  @spec fetch_next_instruction(pid()) :: String.t()
  def fetch_next_instruction(pid) do
    GenServer.call(pid, :fetch_next_instruction, @timeout)
  end

  def handle_call(:fetch_next_instruction, _from, %{sm_stack: [current_sm | _]} = state) do
    reply = GenStateMachine.call(current_sm, :next, @timeout)
    handle_sm_reply(reply, state)
  end

  defp handle_sm_reply(
         {:push_sm, {role, new_sm_state}, instruction},
         %{sm_stack: sm_stack} = state
       ) do
    {:reply, instruction, %{state | sm_stack: [create_sm(role, new_sm_state) | sm_stack]}}
  end

  defp handle_sm_reply(
         {:replace_sm, {role, new_sm_state}, instruction},
         %{sm_stack: [_head | tail]} = state
       ) do
    {:reply, instruction, %{state | sm_stack: [create_sm(role, new_sm_state) | tail]}}
  end

  defp handle_sm_reply({:pop_sm, instruction}, %{sm_stack: [_head | tail]} = state) do
    {:reply, instruction, %{state | sm_stack: tail}}
  end

  defp handle_sm_reply(instruction, state) do
    {:reply, instruction, state}
  end

  # def handle_info(:timeout, %{id: id} = state) do
  #   Logger.error "Digger#{id}: Shutting down due to client inactivity"
  #   {:stop, :normal, state}
  # end

  @spec create_sm(role :: String.t(), state :: map()) :: pid()
  defp create_sm(role, state) do
    case role do
      "idle" -> Turtles.Turtle.Idle.start_link(state)
    end
  end
end

defmodule Turtles.Turtle.Idle do
  use GenStateMachine, callback_mode: :state_functions
  require Logger
  @name __MODULE__

  @spec start_link(data :: map()) :: pid()
  def start_link(data) do
    {:ok, pid} = GenStateMachine.start_link(@name, {:sleeping, data})
    pid
  end

  def sleeping({:call, from}, :next, data) do
    {:keep_state, data, [{:reply, from, "sleep(10)"}]}
  end
end
