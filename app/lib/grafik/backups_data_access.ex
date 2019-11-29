defmodule Grafik.BackupsDataAccess do

  @url Application.get_env(:grafik, :backups_data_access_path)
  @headers ["x-fcstore-secret": Application.get_env(:grafik, :backups_data_access_secret)]
  
  def list() do
    Jason.decode!(HTTPoison.get!(@url, @headers).body)
  end

  def store(stringData) do
    # store stringData on disc, set file to file path
    # get date_now
    # upload using:
    # HTTPoison.post(@url, {:multipart,
    #   {:multipart, [{:file, file, {"form-data", [name: "filedata", filename: Path.basename(file)]}, []}]},
    #   @headears)
  end
  
end
