defmodule Grafik.Projects.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :name, :string
    field :status, :string
    field :sent_note, :string
    field :price, :string
    field :wfirma_invoicecontent_id, :integer
    belongs_to :project, Grafik.Projects.Project
    belongs_to :worker, Grafik.Workers.Worker

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:name, :status, :worker_id, :project_id, :sent_note, :wfirma_invoicecontent_id])
    |> validate_required([:name, :status, :project_id])
  end
end
