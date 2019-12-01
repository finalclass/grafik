defmodule Grafik.BackupsPeriodicRunner do
  use GenServer
  
  alias Grafik.BackupsEngine

  @backups_interval Application.get_env(:grafik, :backups_interval)
  
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work() # Schedule work to be performed at some point
    {:ok, state}
  end

  def handle_info(:work, state) do
    IO.inspect("Running backup")
    result = BackupsEngine.backup_if_changed()
    IO.inspect(result)
    schedule_work() # Reschedule once more
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, @backups_interval)
  end
end
