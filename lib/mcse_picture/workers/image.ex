defmodule McsePicture.Workers.Image do
  use Oban.Worker, queue: :default

  @impl Oban.Worker
  def perform(_job) do
    {:ok, video_path, frame_path} =
      McsePicture.VideoProcessor.download_and_extract_frame(
        "http://192.108.190.142:8080/cgi-bin/mediarecorder_fs.cgi"
      )

    picture = File.read!(frame_path)
    data = Base.encode64(:erlang.term_to_binary(%{date: DateTime.utc_now(), picture: picture}))

    Jackalope.publish("phenocam/lter/picture", data)
    File.rm(frame_path)
    File.rm(video_path)

    :ok
  end
end
