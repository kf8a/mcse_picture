defmodule McsePicture.Workers.Image do
  use Oban.Worker, queue: :default

  @impl Oban.Worker
  def perform(_job) do
    camera_ip = Application.fetch_env!(:mcse_picture, :camera_ip)
    camera_url = "http://#{camera_ip}:8080/cgi-bin/mediarecorder_fs.cgi"

    {:ok, video_path, frame_path} =
      McsePicture.VideoProcessor.download_and_extract_frame(camera_url)

    picture = File.read!(frame_path)
    data = Base.encode64(:erlang.term_to_binary(%{date: DateTime.utc_now(), picture: picture}))

    Tortoise311.publish("mcse_picture", "phenocam/lter/picture", data)
    File.rm(frame_path)
    File.rm(video_path)

    :ok
  end
end
