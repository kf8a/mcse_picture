defmodule McsePicture.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    username = Application.get_env(:mcse_picture, :mqtt_username)
    password = Application.get_env(:mcse_picture, :mqtt_password)
    mqtt_broker_url = Application.get_env(:mcse_picture, :mqtt_broker_url)

    children = [
      # Starts a worker by calling: McsePicture.Worker.start_link(arg)
      # {McsePicture.Worker, arg}
      McsePicture.Repo,
      {Oban, Application.fetch_env!(:mcse_picture, Oban)},
      {Tortoise311.Connection,
       [
         id: "mcse_picture",
         client_id: "mcse_picture",
         server: {Tortoise311.Transport.Tcp, [host: mqtt_broker_url, port: 1884]},
         user_name: username,
         password: password,
         handler: {Tortoise311.Handler.Logger, []},
         clean_session: true
       ]}
      # {Jackalope,
      #  [
      #    client_id: "data_collector",
      #    server: {Tortoise311.Transport.Tcp, [host: "gprpc32.kbs.msu.edu", port: 1884]},
      #    # server:
      #    #   {Tortoise311.Transport.SSL,
      #    #    [cacertfile: :certifi.cacertfile(), host: @amqp_host, port: 8881]},
      #    user_name: @username,
      #    handler: Jackalope.Handler.Logger,
      #    password: @password,
      #    clean_session: true
      #  ]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: McsePicture.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
