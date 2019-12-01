defmodule Grafik.BackupsDataAccess do

  @url Application.get_env(:grafik, :backups_data_access_path)
  @headers ["x-fcstore-secret": Application.get_env(:grafik, :backups_data_access_secret)]

  defp compare_projects_by_deadline(a, b) do
    dateA = a["deadline"] |> DateTime.from_iso8601() |> elem(1) |> DateTime.to_unix()
    dateB = b["deadline"] |> DateTime.from_iso8601() |> elem(1) |> DateTime.to_unix()
    cond do
      dateA - dateB > 0 -> true
      dateA - dateB <= 0 -> false
    end
  end
  
  defp sort_projects(projects) do
    Enum.sort(projects, fn a, b ->
      cond do
        a["is_archived"] == b["is_archived"] ->
          compare_projects_by_deadline(a, b)
        a["is_archived"] && !b["is_archived"] -> true
        true -> false
      end
    end)
  end
  
  defp handle_result(res) do

    
    %{
      lastModified: res["lastModified"] / 1000 |> round() |> DateTime.from_unix() |> elem(1),
      name: res["name"],
      content: case Map.get(res, "content") do
                 nil -> nil
                 content ->
                   content = content |> decode_content()
                   content
                   |> Map.put("projects", sort_projects(content["projects"]))
               end
    }
  end

  defp decode_content(content) do
    content
    |> Base.decode64!()
    |> Jason.decode!() 
 end
  
  def get(backup_name) do
    HTTPoison.get!(Path.join(@url, backup_name), @headers).body
    |> Jason.decode!()
    |> handle_result()
  end
  
  def list() do
    HTTPoison.get!(@url, @headers).body
    |> Jason.decode!()
    |> Enum.map(&handle_result/1)
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
    {:ok, %{status_code: 200}} = HTTPoison.post(@url, {:multipart, [
                                   {:file, file_path, {"form-data", [name: "filedata", filename: Path.basename(file_path)]}, []}]}, @headers)
    File.rm_rf!(file_path)
    file_name
  end
  
end
