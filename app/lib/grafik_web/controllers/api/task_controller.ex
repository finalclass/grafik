defmodule GrafikWeb.Api.TaskController do
  use GrafikWeb, :controller

  alias Grafik.Projects

  def create_empty(conn, %{"project_id" => project_id}) do
    {:ok, task} =
      Projects.create_task(%{
        project_id: project_id,
        name: "Nowe zadanie",
        status: "todo"
      })

    render(conn, "empty-task.json", task: task)
  end
end
