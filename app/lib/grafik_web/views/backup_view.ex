defmodule GrafikWeb.BackupView do
  use GrafikWeb, :view

  defp name_in_list(_list, nil), do: ""
  
  defp name_in_list(list, id) do
    list
    |> Enum.find(fn item -> item["id"] == id end)
    |> Map.get("name")
  end
  
  def client_name(backup, client_id) do
    name_in_list(backup.content["clients"], client_id)
  end
  
  def worker_name(backup, worker_id) do
    name_in_list(backup.content["workers"], worker_id)
  end

  def status_name(backup, status_id) do
    name_in_list(backup.content["statuses"], status_id)
  end
  
  def format_date(str) when is_binary(str) do
    case DateTime.from_iso8601(str) do
      {:error, :missing_offset} ->
        str
        |> NaiveDateTime.from_iso8601!()
        |> DateTime.from_naive!("Etc/UTC")
      {:ok, val, _} -> val 
    end
    |> format_date()
  end

  def format_date(%DateTime{} = d) do
    Integer.to_string(d.year)
    <> "-" <> prefix_zero(d.month)
    <> "-" <> prefix_zero(d.day)
  end

  def format_date(_), do: ""

  def format_date_time(%DateTime{} = d) do
    format_date(d)
    <> " " <> prefix_zero(d.hour)
    <> ":" <> prefix_zero(d.minute)
  end
  
  defp prefix_zero(int) when is_integer(int) do
    prefix_zero(Integer.to_string(int))
  end
  defp prefix_zero(str) when is_binary(str) do
    if String.length(str) == 1 do
      "0" <> str
    else
      str
    end
  end

end
