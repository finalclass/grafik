defmodule Grafik.Repo do
  use Ecto.Repo,
    otp_app: :grafik,
    adapter: Ecto.Adapters.Postgres

  def export_all() do
    %{
      projects: Grafik.Projects.list_projects()
      |> ecto_list_to_map_list()
      |> Enum.map(fn project ->
        Map.put(project, :tasks, ecto_list_to_map_list(project.tasks))
      end),
      clients: ecto_list_to_map_list(Grafik.Clients.list_client()),
      workers: ecto_list_to_map_list(Grafik.Workers.list_workers()),
      statuses: Grafik.Projects.list_statuses()
    }
  end

  def remove_ecto_associations(record) do
    # use pattern matching to check for structs
  end
  
  defp ecto_list_to_map_list(ecto_list) do
    ecto_list |> Enum.map(
      fn record ->
        record |> Map.from_struct() |> Map.delete(:__meta__)
      end)
    
  end
  
end
