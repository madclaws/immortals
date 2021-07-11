defmodule Immortals.GodRegistry do
  @moduledoc """
  Horde Registry implementation
  """

  use Horde.Registry
  require Logger

  def start_link do
    Horde.Registry.start_link(__MODULE__, keys: :unique, name: __MODULE__)
  end

  def init(opts) do
    members()
    |> Keyword.merge(opts)
    |> Horde.Registry.init()
  end

  defp members do
    [Node.self() | Node.list()]
    |> Enum.map(&{__MODULE__, &1})
  end
end
