defmodule McsePicture.Repo do
  use Ecto.Repo,
    otp_app: :mcse_picture,
    adapter: Ecto.Adapters.SQLite3
end
