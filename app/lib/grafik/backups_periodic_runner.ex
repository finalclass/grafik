defmodule Grafik.BackupsPeriodicRunner do
  use GenServer
  
  alias Grafik.BackupsEngine

  @backups_interval Application.get_env(:grafik, :backups_interval)
  
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    backup()
    schedule_work()
    {:ok, state}
  end

  defp backup() do
    IO.inspect("Running backup")
    result = BackupsEngine.backup_if_changed()
    IO.inspect(result)
  end
  
  def handle_info(:work, state) do
    backup()
    schedule_work() # Reschedule once more
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, @backups_interval)
  end
end
