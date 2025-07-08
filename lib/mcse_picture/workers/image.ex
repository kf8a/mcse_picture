defmodule McsePicture.Workers.Image do
  use Oban.Worker, queue: :default

  alias McsePicture.Sun
  require Logger

  @impl Oban.Worker
  def perform(_job) do
    Logger.info("Performing image worker")
    camera_ip = Application.fetch_env!(:mcse_picture, :camera_ip)
    longitude = Application.fetch_env!(:mcse_picture, :longitude)
    latitude = Application.fetch_env!(:mcse_picture, :latitude)
    camera_url = "http://#{camera_ip}:8080/cgi-bin/mediarecorder_fs.cgi"

    if Sun.daytime?({longitude, latitude}, "America/New_York") do
      case McsePicture.VideoProcessor.download_and_extract_frame(camera_url) do
        {:ok, video_path, frame_path} ->
          Logger.info("frame_path: #{frame_path}")
          picture = File.read!(frame_path)

          data =
            Base.encode64(:erlang.term_to_binary(%{date: DateTime.utc_now(), picture: picture}))

          Tortoise311.publish("mcse_picture", "phenocam/lter/picture", data)
          File.rm(frame_path)
          File.rm(video_path)

        {:error, reason} ->
          Logger.error("Error downloading and extracting frame: #{reason}")
          {:error, reason}
      end
    end

    :ok
  end
end
