defmodule WebSocket.EventsTest do
  use ExUnit.Case
  import WebSocket.Events
  @ref :test

  test "start_link/1" do
    calculated = start_link(@ref)

    assert calculated |> elem(0) == :ok
    assert calculated |> elem(1) |> is_pid

    pid = calculated |> elem(1)
    calculated = start_link(@ref)

    assert calculated |> elem(0) == :ok
    assert calculated |> elem(1) |> is_pid
    assert calculated |> elem(1) == pid

    assert stop(@ref) == :ok
  end

  test "subscribe/2" do
    assert {:ok, _} = start_link(@ref)
    assert subscribe(@ref, self()) == :ok
    assert stop(@ref) == :ok
  end

  test "unsubscribe/2" do
    assert {:ok, _} = start_link(@ref)
    assert subscribe(@ref, self()) == :ok
    assert unsubscribe(@ref, self()) == :ok
    assert stop(@ref) == :ok
  end

  test "broadcast/3" do
    assert {:ok, _} = start_link(@ref)
    assert subscribe(@ref, self()) == :ok
    assert broadcast(@ref, {:text, "test"}, self()) == :ok
    refute_receive {:text, "test"}
    assert stop(@ref) == :ok
  end

  test "broadcast!/2" do
    assert {:ok, _} = start_link(@ref)
    assert subscribe(@ref, self()) == :ok
    assert broadcast!(@ref, {:text, "test"}) == :ok
    assert_receive {:text, "test"}
    assert stop(@ref) == :ok
  end

  test "handle_event/2" do
    state = []
    calculated = handle_event({:add_client, self()}, state)

    assert calculated |> elem(0) == :ok
    assert calculated |> elem(1) |> is_list
    assert calculated |> elem(1) == [self()|[]]

    state = calculated |> elem(1)
    calculated = handle_event({:send, {:text, "test"}, nil}, state)

    assert calculated |> elem(0) == :ok
    assert calculated |> elem(1) |> is_list
    assert calculated |> elem(1) == [self()|[]]
    assert_receive {:text, "test"}

    calculated = handle_event({:send, {:text, "test"}, self()}, state)

    assert calculated |> elem(0) == :ok
    assert calculated |> elem(1) |> is_list
    assert calculated |> elem(1) == [self()|[]]
    refute_receive {:text, "test"}

    calculated = handle_event({:remove_client, self()}, state)

    assert calculated |> elem(0) == :ok
    assert calculated |> elem(1) |> is_list
    assert calculated |> elem(1) == []
  end
end
