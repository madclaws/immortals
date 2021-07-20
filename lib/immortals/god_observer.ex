defmodule Immortals.GodObserver do
  @moduledoc """
  Observing the node's up & downs and updating the cluster members
  """

  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    :net_kernel.monitor_nodes(true, node_type: :visible)
    {:ok, []}
  end

  @impl true
  def handle_info({:nodeup, node, _node_type}, state) do
    Process.sleep(1_000)
    Logger.info("Node is up #{inspect(node)}")
    Process.send_after(self(), :on_node_up, 1_000)
    {:noreply, state}
  end

  @impl true
  def handle_info({:nodedown, node, _node_type}, state) do
    Logger.info("Node is down #{inspect(node)}")
    set_members(Immortals.GodSupervisor)
    set_members(Immortals.GodRegistry)
    {:noreply, state}
  end

  @impl true
  def handle_info(:on_node_up, state) do
    Logger.warn("ON NODE UP")
    set_members(Immortals.GodSupervisor)
    set_members(Immortals.GodRegistry)
    join_state_handoff()
    {:noreply, state}
  end

  defp set_members(god_process) do
    [Node.self() | Node.list()]
    |> Enum.map(&{god_process, &1})
    |> then(&Horde.Cluster.set_members(god_process, &1))
  end

  defp join_state_handoff() do
    Node.list()
    |> Enum.map(&Immortals.StateHandoff.join/1)
  end
end
