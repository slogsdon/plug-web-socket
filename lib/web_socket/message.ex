defmodule WebSocket.Message do
  @moduledoc """
  Wrapper for defining WebSocket messages
  """

  defstruct event: nil, data: nil
  @type t :: %__MODULE__{
    event: binary,
    data: Map.t
  }

  @spec build(binary, Map.t) :: t
  def build(event, data) do
    %__MODULE__{
      event: event,
      data: data
    }
  end
end
