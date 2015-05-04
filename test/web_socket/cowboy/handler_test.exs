defmodule WebSocket.Cowboy.HandlerTest do
  use ExUnit.Case
  import WebSocket.Cowboy.Handler
  @ref :test

  test "init/3" do
    calculated = init(:tcp, nil, {__MODULE__, @ref})

    assert calculated |> elem(0) == :upgrade
    assert calculated |> elem(1) == :protocol
    assert calculated |> elem(2) == :cowboy_websocket
  end
end
