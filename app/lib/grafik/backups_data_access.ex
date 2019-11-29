defmodule Grafik.BackupsDataAccess do

  @url Application.get_env(:grafik, :backups_data_access_path)
  @headers ["x-fcstore-secret": Application.get_env(:grafik, :backups_data_access_secret)]
  
  def list() do
    Jason.decode!(HTTPoison.get!(@url, @headers).body)
  end
  
end
