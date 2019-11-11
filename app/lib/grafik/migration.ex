defmodule Grafik.ReleaseTasks do
  def migrate do
    {:ok, _} = Application.ensure_all_started(:grafik)

    path = Application.app_dir(:grafik, "priv/repo/migrations")

    Ecto.Migrator.run(Grafik.Repo, path, :up, all: true)
  end
end
