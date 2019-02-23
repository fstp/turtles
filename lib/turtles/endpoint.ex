defmodule Turtles.Endpoint do
  use Plug.Router
  require Logger

  plug(Plug.Parsers, parsers: [:urlencoded])
  plug(:match)
  plug(:dispatch)

  def start_link() do
    # NOTE: This starts Cowboy listening on the default port of 4000
    {:ok, _} = Plug.Adapters.Cowboy.http(__MODULE__, [])
  end

  def init(options) do
    options
  end

  get "/init" do
    send_resp(conn, 200, start_worker() |> to_string())
  end

  get "/fetch" do
    {status, body} =
      case Plug.Conn.Query.decode(conn.query_string) do
        %{"id" => id} ->
          case to_non_neg_integer(id) do
            {:ok, id} -> {200, fetch_next_instruction(id)}
            :error -> {400, "invalid id"}
          end

        _ ->
          {400, "missing id"}
      end

    send_resp(conn, status, body)
  end

  post "/result" do
    {status, body} =
      case conn.params do
        %{"id" => _id, "result" => _result} ->
          {200, ""}

        _ ->
          {400, "missing id"}
      end

    send_resp(conn, status, body)
  end

  @spec to_non_neg_integer(id :: String.t()) :: {:ok, non_neg_integer()} | :error
  defp to_non_neg_integer(id) do
    case Integer.parse(id) do
      {id, ""} when id >= 0 -> {:ok, id}
      _ -> :error
    end
  end

  @spec start_worker() :: non_neg_integer()
  defp start_worker() do
    id = Turtles.TurtleRegistry.generate_id()
    {:ok, _pid} = Turtles.TurtleSupervisor.start_turtle(id)
    id
  end

  @spec fetch_next_instruction(id :: non_neg_integer()) :: String.t()
  defp fetch_next_instruction(id) do
    case Turtles.TurtleRegistry.get_pid(id) do
      {:ok, pid} ->
        ins = Turtles.Turtle.fetch_next_instruction(pid)
        #Logger.info(ins)
        ins

      {:error, :not_found} ->
        Logger.error("#{id} not found in registry")
        ":retry"
    end
  end
end
