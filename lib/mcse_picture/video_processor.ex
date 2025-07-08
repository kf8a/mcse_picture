defmodule McsePicture.VideoProcessor do
  require Logger

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
    cmd =
      [
        "-i",
        input_path,
        "-ss",
        time_str,
        "-frames:v",
        "1",
        # Overwrite output file if it exists
        "-y",
        "#{output_path}"
      ]
      |> IO.inspect(label: "cmd")

    case System.cmd("ffmpeg", cmd, stderr_to_stdout: true) do
      {_output, 0} ->
        {:ok, "#{output_path}"}

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
    {:ok, frame_path} = Briefly.create(extname: ".jpg", prefix: "mcse_picture_")

    case download_video(url) do
      {:ok, video_filename} ->
        case extract_frame(video_filename, frame_path, time_seconds) do
          {:ok, frame_path} ->
            {:ok, video_filename, frame_path}

          {:error, reason} ->
            {:error, "Frame extraction failed: #{reason}"}
        end

      {:error, reason} ->
        {:error, "Video download failed: #{reason}"}
    end
  end

  defp download_video(url) do
    {:ok, temp_path} = Briefly.create(extname: ".flv")
    Logger.info("Downloading video from #{url} to #{temp_path}")

    cmd = ["-m", "60", "-s", "-o", temp_path, url]

    {output, exit_code} =
      System.cmd("/usr/bin/curl", cmd, stderr_to_stdout: true)

    case exit_code do
      0 ->
        {:ok, temp_path}

      28 ->
        {:ok, temp_path}

      _ ->
        {:error, "Curl failed with exit code #{exit_code}: #{output}"}
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
