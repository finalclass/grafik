defmodule Grafik.BackupsDataAccess do

  @url Application.get_env(:grafik, :backups_data_access_path)
  @headers ["x-fcstore-secret": Application.get_env(:grafik, :backups_data_access_secret)]
  
  def list() do
    Jason.decode!(HTTPoison.get!(@url, @headers).body)
  end

  defp prefix_zero(time) when is_integer(time) do
    prefix_zero(Integer.to_string(time))
  end

  defp prefix_zero(timeString) do
    if String.length(timeString) == 1 do
      "0" <> timeString
    else
      timeString
    end
  end

  defp round_to_quarter_of_an_hour(minutes) do
    if minutes < 15 do "00"
    else if minutes < 30 do "15"
    else if minutes < 45 do "30"
    else "45"
    end end end
  end
      
  def store(binData) do
    {:ok, now} = DateTime.now("Etc/UTC")
    file_name = prefix_zero(now.day) <> "-" <> prefix_zero(now.hour) <> "-" <> round_to_quarter_of_an_hour(now.minute) <> ".json"
    file_path = Path.join(System.tmp_dir!(), file_name)
    File.write(file_path, binData)
    HTTPoison.post(@url, {:multipart, [
                             {:file, file_path, {"form-data", [name: "filedata", filename: Path.basename(file_path)]}, []}]}, @headers)
    File.rm_rf!(file_path)
  end
  
end
