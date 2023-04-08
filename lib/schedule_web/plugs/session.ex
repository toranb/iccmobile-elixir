defmodule ScheduleWeb.Plug.Session do
  import Plug.Conn, only: [get_session: 2, put_session: 3]

  @spec validate_session(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def validate_session(conn, _opts) do
    case get_session(conn, :session_uuid) do
      nil ->
        conn
        |> put_session(:session_uuid, Ecto.UUID.generate())

      _session_uuid ->
        conn
    end
  end
end
