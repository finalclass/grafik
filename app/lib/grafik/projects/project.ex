defmodule Grafik.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset
  
  schema "projects" do
    field :deadline, :date
    field :name, :string
    field :is_archived, :boolean
    belongs_to :client, Grafik.Clients.Client
    has_many :tasks, Grafik.Projects.Task

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :deadline, :client_id, :is_archived])
    |> validate_required([:name, :deadline, :client_id])
  end
end
