defmodule Grafik.BackupsEngine do

  alias Grafik.Repo
  alias Grafik.BackupsDataAccess
  
  def backup() do
    Jason.encode!(Repo.export_all()) |> BackupsDataAccess.store()
  end
  
end
