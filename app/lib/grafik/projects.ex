defmodule Grafik.Projects do
  @moduledoc """
  The Projects context.
  """

  import Ecto.Query, warn: false
  alias Grafik.Repo

  alias Grafik.Projects.Project
  alias Grafik.Projects.Task

  def list_statuses() do
    [
      %{id: "todo", name: "Nieruszony"},
      %{id: "in_propress", name: "Realizowany"},
      %{id: "received", name: "Odebrany"},
      %{id: "sent", name: "Wysłany"}
    ]
  end

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects()
      [%Project{}, ...]

  """
  def list_projects do
    Repo.all query_full_projects()
  end

  def list_not_archived_projects do
    query = query_full_projects()
    
    from(p in query, where: p.is_archived == false)
      |> Repo.all
  end
  
  def query_full_projects do
    task_query = from t in Task, preload: [:worker], order_by: t.id
    client_query = from c in Grafik.Clients.Client
    
    from p in Project,
      order_by: [asc: p.is_archived, asc: p.deadline],
      preload: [
        tasks: ^task_query,
        client: ^client_query
      ]
    
  end
    
  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(id) do
    Project
    |> Repo.get!(id)
    |> Repo.preload(:client)
  end

  def get_project_with_tasks!(id) do
    query = query_full_projects()
    Repo.one(from(p in query, where: (p.id == ^id)))
  end

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(%{field: value})
      {:ok, %Project{}}

      iex> create_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{source: %Project{}}

  """
  def change_project(%Project{} = project) do
    Project.changeset(project, %{})
  end

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks()
      [%Task{}, ...]

  """
  def list_tasks do
    Task
    |> Repo.all()
    |> Repo.preload(:project)
    |> Repo.preload(:worker)
  end

  @doc """
  Gets a single task.

  Raises `Ecto.NoResultsError` if the Task does not exist.

  ## Examples

      iex> get_task!(123)
      %Task{}

      iex> get_task!(456)
      ** (Ecto.NoResultsError)

  """
  def get_task!(id) do
    Task
    |> Repo.get!(id)
    |> Repo.preload(:project)
    |> Repo.preload(:worker)
  end

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %Task{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a task.

  ## Examples

      iex> update_task(task, %{field: new_value})
      {:ok, %Task{}}

      iex> update_task(task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_task(%Task{} = task, attrs) do
    # if we change to "sent" add "sent_at" with current time
    attrs = if (task.status !== "sent" && attrs["status"] === "sent") do
      now = DateTime.utc_now()
      Map.put(attrs, "sent_at",
        %{
          "year" => Integer.to_string(now.year),
          "month" => Integer.to_string(now.month),
          "day" => Integer.to_string(now.day),
          "hour" => Integer.to_string(now.hour),
          "minute" => Integer.to_string(now.minute)
        }
      )
    else
      attrs
    end

    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Task.

  ## Examples

      iex> delete_task(task)
      {:ok, %Task{}}

      iex> delete_task(task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.

  ## Examples

      iex> change_task(task)
      %Ecto.Changeset{source: %Task{}}

  """
  def change_task(%Task{} = task) do
    Task.changeset(task, %{})
  end

  def get_worker_tasks!(worker_id) do
    tasks_q = from t in Task, where: t.worker_id == ^worker_id
    client_q = from c in Grafik.Clients.Client
    Repo.all(
      from p in Project,
      join: t in Task,
      on: t.project_id == p.id,
      where: t.worker_id == ^worker_id,
      group_by: p.id,
      preload: [
        tasks: ^tasks_q,
        client: ^client_q
      ]
    )
  end
end
