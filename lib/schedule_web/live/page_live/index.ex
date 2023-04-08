defmodule ScheduleWeb.PageLive.Index do
  use ScheduleWeb, :live_view

  import Jason.Sigil

  @impl true
  def mount(_params, _session, socket) do
    sessions =
      get_sessions()["data"]
      |> Schedule.Util.deep_atomize()
      |> Enum.with_index()
      |> Enum.map(fn {session, i} -> Map.put(session, :id, "session#{i}") end)

    {:ok, assign(socket, everything: sessions)}
  end

  @impl true
  def handle_event("rate", %{"id" => _id, "star" => _star}, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h2>Iowa Code Camp</h2>
    <%= for session <- @everything do %>
      <.conference_session session={session} />
    <% end %>
    """
  end

  def get_sessions() do
    ~J"""
      {
        "data": []
      }
    """
  end
end
