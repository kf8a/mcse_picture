import Config

# Configure Oban with SQLite3
config :mcse_picture, Oban,
  engine: Oban.Engines.Lite,
  repo: McsePicture.Repo,
  plugins: [
    {Oban.Plugins.Pruner, max_age: 60 * 60 * 24 * 7},
    {Oban.Plugins.Cron,
     crontab: [
       {"*/30 4-22 * * *", McsePicture.Workers.Image}
     ]}
  ]

# Configure the database
config :mcse_picture, McsePicture.Repo,
  database: "mcse_picture.db",
  pool_size: 10

# Configure Ecto
config :mcse_picture,
  ecto_repos: [McsePicture.Repo]

import_config "#{config_env()}.exs"
