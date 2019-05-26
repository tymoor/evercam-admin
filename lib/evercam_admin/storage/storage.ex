defmodule EvercamAdmin.Storage do

  use GenServer
  require Logger

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def init(_args) do
    Logger.info "Start"
    {:ok, 1}
  end
end