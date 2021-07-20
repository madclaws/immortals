defmodule Immortals.StateHandoff do
  @moduledoc """
  Process that handles the DeltaCRDT to store states across cluster
  """
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def join(node) do
    GenServer.call(__MODULE__, {:add_node, {__MODULE__, node}})
  end

  def handoff(name, age) do
    GenServer.call(__MODULE__, {:handleoff, name, age})
  end

  def get_age(name) do
    GenServer.call(__MODULE__, {:get_age, name})
  end

  @impl true
  def init(_opts) do
    {:ok, crdt_pid} = DeltaCrdt.start_link(DeltaCrdt.AWLWWMap, sync_interval: 5)
    Logger.warn("Statehandoff inited at #{inspect Node.self}")
    {:ok, crdt_pid}
  end

  @impl true
  def handle_call({:add_node, node_module}, _from, crdt_pid) do
    Logger.warn(inspect node_module)
    other_crdt_pid = GenServer.call(node_module, {:ack_add_node, crdt_pid})
    DeltaCrdt.set_neighbours(crdt_pid, [other_crdt_pid])
    {:reply, :ok, crdt_pid}
  end

  @impl true
  def handle_call({:ack_add_node, other_crdt_pid}, _from, crdt_pid) do
    Logger.warn("ACK request from inspect other node")
    DeltaCrdt.set_neighbours(crdt_pid, [other_crdt_pid])
    {:reply, crdt_pid, crdt_pid}
  end

  @impl true
  def handle_call({:handleoff, name, age}, _from, crdt_pid) do
    DeltaCrdt.put(crdt_pid, name, age)
    # Logger.info("Added #{name} to purgatory")
    # I have no idea, if we comment the next line, CRDT will not work.
    # IO.inspect(DeltaCrdt.to_map(crdt_pid))
    {:reply, :ok, crdt_pid}
  end

  @impl true
  def handle_call({:get_age, name}, _from, crdt_pid) do
    Logger.warn("Getting Age of #{name} #{inspect(DeltaCrdt.to_map(crdt_pid))}")
    age = DeltaCrdt.to_map(crdt_pid) |> Map.get(name, 0)
    DeltaCrdt.delete(crdt_pid, name)
    {:reply, age, crdt_pid}
  end
end
