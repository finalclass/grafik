# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
use Mix.Config

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

config :grafik, Grafik.Repo,
  # ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :grafik, GrafikWeb.Endpoint,
  server: true,
  http: [:inet6, port: String.to_integer(System.get_env("PORT") || "4000")],
  secret_key_base: secret_key_base

config :grafik, :backups_data_access_secret, System.get_env("X_FCSTORE_SECRET") || raise """
environment variable X_FCSTORE_SECRET is missing
"""

config :grafik, :wfirma_login, System.get_env("WFIRMA_LOGIN") || raise """
environment variable WFIRMA_LOGIN is missing
"""
config :grafik, :wfirma_password, System.get_env("WFIRMA_PASSWORD") || raise ""
environment variable WFIRMA_PASSWORD is missing
""'


# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :grafik, GrafikWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
