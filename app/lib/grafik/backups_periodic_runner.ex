defmodule Grafik.BackupsPeriodicRunner do
  use GenServer
  
  alias Grafik.BackupsEngine

  @backups_interval Application.get_env(:grafik, :backups_interval)
  
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work(30_000)
    {:ok, state}
  end
  
  def handle_info(:work, state) do
    IO.inspect("Running backup")
    result = BackupsEngine.backup_if_changed()
    IO.inspect(result)
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    schedule_work(@backups_interval)
  end
  
  defp schedule_work(interval) do
    Process.send_after(self(), :work, interval)
  end
end
