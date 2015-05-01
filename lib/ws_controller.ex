defmodule WsController do
  def echo(:init, state) do
    {:ok, state}
  end
  def echo(:terminate, _state) do
    :ok
  end
  def echo(message, state)do
    {:reply, {:text, message}, state}
  end
end
