defmodule Immortals.GodSupervisor do
  @moduledoc """
  Horde DynamicSupervisor implementation
  """

  use Horde.DynamicSupervisor
  require Logger

  def start_link(_) do
    Horde.DynamicSupervisor.start_link(__MODULE__, strategy: :one_for_one, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    members()
    |> Keyword.merge(opts)
    |> Horde.DynamicSupervisor.init()
  end

  def start_child(child_spec) do
    Horde.DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  defp members do
    [Node.self() | Node.list()]
    |> tap(&Logger.info(inspect(&1)))
    |> Enum.map(&{__MODULE__, &1})
  end
end
