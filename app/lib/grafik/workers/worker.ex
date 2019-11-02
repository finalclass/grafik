defmodule Grafik.Workers.Worker do
  use Ecto.Schema
  import Ecto.Changeset

  schema "workers" do
    field :name, :string
    has_many :tasks, Grafik.Projects.Task

    timestamps()
  end

  @doc false
  def changeset(worker, attrs) do
    worker
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
