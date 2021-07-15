defmodule Immortals.Life do
  @moduledoc """
  This is where the brain of an organisms exist
  """

  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: via_tuple(opts[:name]))
  end

  @spec get_age(name :: atom()) :: number()
  def get_age(name) do
    GenServer.call(via_tuple(name), :age)
  end

  @impl true
  def init(opts) do
    Logger.info("New life spawned to universe => #{opts[:name]}")
    Process.flag(:trap_exit, true)
    current_age = Immortals.StateHandoff.get_age(opts[:name])
    Logger.info("#{opts[:name]}'s current age is #{current_age}")
    Process.send_after(self(), :heartbeat, 1_000)
    {:ok, %{age: current_age, name: opts[:name]}}
  end

  @impl true
  def handle_call(:age, _from, %{age: current_age} = state) do
    {:reply, current_age, state}
  end

  @impl true
  def handle_info(:heartbeat, %{age: current_age} = state) do
    Process.send_after(self(), :heartbeat, 1_000)
    {:noreply, %{state | age: current_age + 1}}
  end

  @impl true
  def terminate(reason, %{name: name, age: age} = _state) do
    Logger.info("#{name} died due to #{inspect(reason)}")
    Immortals.StateHandoff.handoff(name, age)
    :ok
  end

  defp via_tuple(name) do
    {:via, Horde.Registry, {Immortals.GodRegistry, name}}
  end
end
