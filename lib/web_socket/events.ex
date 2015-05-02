defmodule WebSocket.Events do
  use GenEvent

  ## Public API

  def start_link(ref) do
    case GenEvent.start_link(name: ref) do
      {:ok, pid} ->
        GenEvent.add_handler(ref, __MODULE__, [])
        {:ok, pid}
      {:error, {:already_started, pid}} ->
        {:ok, pid}
      otherwise ->
        otherwise
    end
  end

  def join(ref, pid) do
    GenEvent.notify(ref, {:add_client, pid})
  end

  def leave(ref, pid) do
    GenEvent.notify(ref, {:remove_client, pid})
  end

  def broadcast(ref, event, originator) do
    GenEvent.notify(ref, {:send, event, originator})
  end

  def broadcast!(ref, event) do
    broadcast(ref, event, nil)
  end

  def stop(ref) do
    GenEvent.stop(ref)
  end

  ## Callbacks

  def handle_event({:add_client, pid}, clients) do
    {:ok, [pid|clients]}
  end

  def handle_event({:remove_client, pid}, clients) do
    {:ok, clients |> Enum.filter(&(&1 != pid))}
  end

  def handle_event({:send, event, originator}, clients) do
    spawn fn ->
      clients |> Enum.map(&(maybe_send(&1, originator, event)))
    end
    {:ok, clients}
  end

  defp maybe_send(client, originator, event) do
    unless client == originator do
      send client, event
    end
  end
end
