defmodule Grafik.Clients.Client do
  use Ecto.Schema
  import Ecto.Changeset

  schema "clients" do
    field :name, :string
    field :wfirma_id, :string
    has_many :projects, Grafik.Projects.Project

    timestamps()
  end

  @doc false
  def changeset(client, attrs) do
    client
    |> cast(attrs, [:name, :wfirma_id])
    |> validate_required([:name])
  end
end
