defmodule WebSocket.MessageTest do
  use ExUnit.Case
  import WebSocket.Message
  alias WebSocket.Message

  test "build/2" do
    # string
    assert build("event1", nil) ==
      %Message{event: "event1", data: nil}
    assert build("event2", "data") ==
      %Message{event: "event2", data: "data"}

    # map/struct
    assert build("event3", %{foo: :bar}) ==
      %Message{event: "event3", data: %{foo: :bar}}
    assert build("event4", %Message{data: :blah}) ==
      %Message{event: "event4", data: %Message{data: :blah}}
  end
end
