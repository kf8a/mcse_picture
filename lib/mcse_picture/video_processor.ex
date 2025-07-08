defmodule McsePicture.VideoProcessor do
  @doc """
  Extracts a single frame from a video file at the specified time.

  ## Parameters
  - input_path: Path to the input video file
  - output_path: Path for the output image (without extension)
  - time_seconds: Time in seconds to extract frame from (default: 8)

  ## Returns
  - {:ok, output_path} on success
  - {:error, reason} on failure
  """
  def extract_frame(input_path, output_path, time_seconds \\ 8) do
    # Convert seconds to HH:MM:SS format
    time_str = format_time(time_seconds)

    # Build the ffmpeg command
    cmd = [
      "ffmpeg",
      "-i",
      input_path,
      "-ss",
      time_str,
      "-frames:v",
      "1",
      # Overwrite output file if it exists
      "-y",
      "#{output_path}.jpg"
    ]

    case System.cmd("ffmpeg", cmd, stderr_to_stdout: true) do
      {_output, 0} ->
        {:ok, "#{output_path}.jpg"}

      {error_output, exit_code} ->
        {:error, "FFmpeg failed with exit code #{exit_code}: #{error_output}"}
    end
  end

  @doc """
  Downloads a video and extracts a frame from it.

  ## Parameters
  - url: URL to download the video from
  - time_seconds: Time in seconds to extract frame from (default: 8)

  ## Returns
  - {:ok, video_path, frame_path} on success
  - {:error, reason} on failure
  """
  def download_and_extract_frame(url, time_seconds \\ 8) do
    # Generate timestamp for filenames
    now = DateTime.utc_now() |> Calendar.strftime("%Y%m%d_%H%M%S")
    video_filename = "#{now}.flv"
    frame_filename = "#{now}_frame"

    # Download the video
    case download_video(url, video_filename) do
      {:ok, _} ->
        # Extract frame from the downloaded video
        case extract_frame(video_filename, frame_filename, time_seconds) do
          {:ok, frame_path} ->
            {:ok, video_filename, frame_path}

          {:error, reason} ->
            {:error, "Frame extraction failed: #{reason}"}
        end

      {:error, reason} ->
        {:error, "Video download failed: #{reason}"}
    end
  end

  defp download_video(url, filename) do
    case Req.get(url,
           timeout: 60_000,
           into: File.stream!(filename)
         ) do
      {:ok, _response} ->
        {:ok, filename}

      {:error, error} ->
        {:error, "Download failed: #{inspect(error)}"}
    end
  end

  defp format_time(seconds) do
    hours = div(seconds, 3600)
    minutes = div(rem(seconds, 3600), 60)
    secs = rem(seconds, 60)

    :io_lib.format("~2..0B:~2..0B:~2..0B", [hours, minutes, secs])
    |> to_string()
  end
end
