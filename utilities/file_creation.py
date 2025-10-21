"""
Video file creation with muxing of audio and subtitle tracks.

Handles the creation of MKV video files with multiple audio and subtitle tracks,
properly tagged with language metadata using mkvmerge.
"""
import os
import subprocess

from utilities.exceptions import (
    ComponentNotFoundException,
    InvalidLanguageException, Failed
)


def create_video_file(video_path: str, settings: dict) -> None:
    """
    Creates an MKV video file with multiple audio and subtitle tracks,
    properly tagged with language metadata.

    Args:
    """

    # --- Input Validation ---
    video_file = f"{settings['resolution']}.mp4"
    if not os.path.exists(video_file):
        raise ComponentNotFoundException(f"Error: Video file not found at '{video_file}'")

    for lang_code in settings['audio_tracks']:
        audio_path = f"sounds/1-min-audio-{lang_code}.aac"
        if not os.path.exists(audio_path):
            raise ComponentNotFoundException(f"Error: Audio file not found at '{audio_path}'")
        if not isinstance(lang_code, str) or len(lang_code) != 3:
            raise InvalidLanguageException(f"Invalid language code '{lang_code}' for audio file '{audio_path}'. Must be 3 letters.")

    for lang_code in settings['subtitle_tracks']:
        subtitle_path = f"subs/sub.{lang_code}.srt"
        if not os.path.exists(subtitle_path):
            raise ComponentNotFoundException(f"Error: Subtitle file not found at '{subtitle_path}'")
        if not isinstance(lang_code, str) or len(lang_code) != 3:
            raise InvalidLanguageException(f"Invalid language code '{lang_code}' for subtitle file '{subtitle_path}'. Must be 3 letters.")

    # --- Construct FFmpeg Command ---
    command = ["ffmpeg"]

    # Add video input
    command.extend(["-i", video_file])

    # Add audio inputs and keep track of their original input index
    # Input index starts from 0 for the first -i, so video is 0.
    # Audio inputs will start from index 1.
    current_input_index = 1
    for lang_code in settings['audio_tracks']:
        audio_path = f"sounds/1-min-audio-{lang_code}.aac"
        command.extend(["-i", audio_path])
        current_input_index += 1

    # Add subtitle inputs
    # Subtitle inputs will follow audio inputs.
    for lang_code in settings['subtitle_tracks']:
        subtitle_path = f"subs/sub.{lang_code}.srt"
        command.extend(["-i", subtitle_path])
        current_input_index += 1

    # --- Stream Mapping ---
    # Map video stream from the first input (index 0)
    command.extend(["-map", "0:v"])

    # Map audio streams and add language metadata
    # The output stream index for audio starts from 0 (s:a:0, s:a:1, etc.)
    audio_output_stream_index = 0
    audio_input_start_index = 1 # Audio files start from input index 1
    for i, lang_code in enumerate(settings['audio_tracks']):
        # Map current audio input to an audio stream in the output
        command.extend(["-map", f"{audio_input_start_index + i}:a"])
        # Add language metadata for this audio stream in the output
        command.extend([f"-metadata:s:a:{audio_output_stream_index}", f"language={lang_code}"])
        audio_output_stream_index += 1

    # Map subtitle streams and add language metadata
    # The output stream index for subtitle starts from 0 (s:s:0, s:s:1, etc.)
    subtitle_output_stream_index = 0
    # Subtitle input start index is 1 (video) + number of audio tracks
    subtitle_input_start_index = 1 + len(settings['audio_tracks'])
    for i, lang_code in enumerate(settings['subtitle_tracks']):
        # Map current subtitle input to a subtitle stream in the output
        command.extend(["-map", f"{subtitle_input_start_index + i}:s"])
        # Add language metadata for this subtitle stream in the output
        command.extend([f"-metadata:s:s:{subtitle_output_stream_index}", f"language={lang_code}"])
        subtitle_output_stream_index += 1

    # Set output format to MKV (optional, but good for clarity)
    command.extend(["-c", "copy"]) # Copy streams without re-encoding for speed
    command.append(video_path)

    # print(f"Generated FFmpeg command:\n{' '.join(command)}\n")

    # --- Execute FFmpeg Command ---
    try:
        # Run the command
        # capture_output=True captures stdout and stderr
        # text=True decodes stdout/stderr as text
        # check=True raises CalledProcessError if the command returns a non-zero exit code
        process = subprocess.run(command, capture_output=True, text=True, check=True)
        if process.returncode == 0:
            print(f"Successfully created '{video_path}'")
        else:
            print(f"Error creating '{video_path}': {process.returncode}")
            raise Failed(f"Error creating '{video_path}': {process.returncode}")
        # print("FFmpeg Output (stdout):\n", process.stdout)
        # print("FFmpeg Errors (stderr):\n", process.stderr) # FFmpeg often prints progress to stderr
    except subprocess.CalledProcessError as e:
        print("Error during FFmpeg execution:")
        print(f"Command: {e.cmd}")
        print(f"Return Code: {e.returncode}")
        print(f"Stdout: {e.stdout}")
        print(f"Stderr: {e.stderr}")
        raise Failed("Error during FFmpeg execution") from e
    except Exception as e:
        raise e
