defmodule WebSocket.TopicController do
  def handle(:init, state) do
    {:ok, state}
  end
  def handle(:terminate, _state) do
    :ok
  end
  def handle("topic:" <> letter, state, data) do
    payload = %{awesome: "blah #{letter}", 
                orig: data}
    {:reply, {:text, payload}, state}
  end
end
