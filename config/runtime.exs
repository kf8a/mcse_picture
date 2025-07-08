import Config

if config_env() != :test do
  config :mcse_picture,
    mqtt_username: System.fetch_env!("MQTT_USERNAME"),
    mqtt_password: System.fetch_env!("MQTT_PASSWORD"),
    mqtt_broker_url: System.fetch_env!("MQTT_BROKER_URL"),
    camera_ip: System.fetch_env!("CAMERA_IP")
end
