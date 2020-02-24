defmodule Grafik.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :deadline, :utc_datetime
    field :name, :string
    field :description, :string
    field :is_archived, :boolean
    field :invoice_number, :string
    field :price, :float
    field :paid, :float
    field :start_at, :utc_datetime
    field :is_deadline_rigid, :boolean

    belongs_to :client, Grafik.Clients.Client
    has_many :tasks, Grafik.Projects.Task

    timestamps()
  end

  defp ensure_correct_time(time) when is_integer(time),
    do: (time / 1000) |> round() |> DateTime.from_unix() |> elem(1)

  defp ensure_correct_time(time), do: time

  @doc false
  def changeset(project, attrs) do
    attrs = %{
      attrs
      | "deadline" => ensure_correct_time(attrs["deadline"]),
        "start_at" => ensure_correct_time(attrs["start_at"])
    }

    IO.inspect(attrs)

    project
    |> cast(attrs, [
      :name,
      :description,
      :deadline,
      :client_id,
      :is_archived,
      :invoice_number,
      :price,
      :paid,
      :start_at,
      :is_deadline_rigid
    ])
    |> validate_required([:name, :deadline, :client_id])
  end

end
