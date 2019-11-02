defmodule Grafik.Repo do
  use Ecto.Repo,
    otp_app: :grafik,
    adapter: Ecto.Adapters.Postgres
end
