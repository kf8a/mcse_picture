defmodule McsePicture.Workers.Image do
  use Oban.Worker, queue: :default

  require Logger

  @impl Oban.Worker
  def perform(_job) do
    Logger.info("Capturing image")
    camera_ip = Application.fetch_env!(:mcse_picture, :camera_ip)
    camera_url = "http://#{camera_ip}:8080/cgi-bin/mediarecorder_fs.cgi"

    case McsePicture.VideoProcessor.download_and_extract_frame(camera_url) do
      {:ok, _video_path, frame_path} ->
        Logger.info("Got image at frame_path: #{frame_path}")
        picture = File.read!(frame_path)

        if byte_size(picture) > 0 do
          data =
            Base.encode64(:erlang.term_to_binary(%{date: DateTime.utc_now(), picture: picture}))

          Tortoise311.publish("mcse_picture", "phenocam/1-lter/picture", data)
        else
          Logger.error("No data to publish")
        end

      {:error, reason} ->
        Logger.error("Error downloading and extracting frame: #{reason}")
        {:error, reason}
    end

    Briefly.cleanup()
    :ok
  end
end
