defmodule Grafik.Projects.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :description, :string
    field :name, :string
    field :status, :string
    belongs_to :project, Grafik.Projects.Project
    belongs_to :worker, Grafik.Workers.Worker

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:name, :status, :description, :worker_id, :project_id])
    |> validate_required([:name, :status, :project_id])
  end
end
