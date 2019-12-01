defmodule Grafik.BackupsEngine do

  alias Grafik.Repo
  alias Grafik.BackupsDataAccess

  defp current_state() do
    Jason.encode!(Repo.export_all())
  end
  
  def backup() do
     current_state() |> BackupsDataAccess.store()
  end

  def backup_if_changed() do
    curr = current_state()
    latest_stored = BackupsDataAccess.get_latest_raw()

    if (curr != latest_stored) do
      backup()
      :backup
    else
      :not_changed
    end
  end
  
end
