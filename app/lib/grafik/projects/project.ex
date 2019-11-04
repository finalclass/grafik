defmodule Grafik.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset
  
  schema "projects" do
    field :deadline, :date
    field :name, :string
    field :is_archived, :boolean
    field :invoice_number, :string
    field :price, :float
    field :paid, :float
    field :start_at, :date
    field :is_deadline_rigid, :boolean
    
    belongs_to :client, Grafik.Clients.Client
    has_many :tasks, Grafik.Projects.Task

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [
          :name,
          :deadline,
          :client_id,
          :is_archived,
          :invoice_number,
          :price,
          :paid,
          :start_at,
          :is_deadline_rigid,
        ])
    |> validate_required([:name, :deadline, :client_id])
  end
end
