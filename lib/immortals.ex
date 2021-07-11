defmodule Immortals do
  @moduledoc """
  Documentation for `Immortals`.
  """
  @spec start_life(name :: String.t()) :: any()
  def start_life(name) do
    child_spec = %{
      id: Immortals.Life,
      start: {Immortals.Life, :start_link, [[name: name]]}
    }

    Immortals.GodSupervisor.start_child(child_spec)
  end

  @spec get_age(name :: String.t()) :: any()
  def get_age(name) do
    Immortals.Life.get_age(name)
  end

  @spec kill(name :: String.t()) :: any()
  def kill(name) do
    GenServer.whereis({:via, Horde.Registry, {Immortals.GodRegistry, name}})
    |> Process.exit(:kill)
  end
end
