defmodule McsePicture.Sun do
  @moduledoc """
  Utilities for astronomical calculations.
  """

  @doc """
  Returns true if the current time is after sunrise and before sunset for the given location and date.

  ## Parameters
    - latitude: float (e.g., 40.7128)
    - longitude: float (e.g., -74.0060)
    - tz: IANA time zone string (e.g., "America/New_York")
    - date: Date struct (optional, defaults to today)
    - now: DateTime struct (optional, defaults to DateTime.now! in tz)

  ## Returns
    - true if now is after sunrise and before sunset, false otherwise
  """
  def daytime?({longitude, latitude}, tz, now \\ nil) do
    # Get current time in the specified timezone if not provided
    now =
      now ||
        DateTime.now!(tz)

    # Calculate sunrise and sunset times
    {:ok, sunrise} = Astro.sunrise({longitude, latitude}, DateTime.to_date(now))
    {:ok, sunset} = Astro.sunset({longitude, latitude}, DateTime.to_date(now))

    DateTime.compare(now, sunrise) == :gt and DateTime.compare(now, sunset) == :lt
  end
end
