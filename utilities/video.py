from pathlib import Path
import random
import subprocess

sources = ['Bluray', 'Remux', 'WEBDL', 'WEBRIP', 'HDTV', 'DVD']

resolutions = ['2160p', '1080p', '720p', '576p', '480p', '360p', '240p']

editions = ['{edition-Extended Edition} ', '{edition-Uncut Edition} ', '{edition-Unrated Edition} ', '{edition-Special Edition} ', '{edition-Anniversary Edition} ', '{edition-Collectors Edition} ', '{edition-Diamond Edition} ', '{edition-Platinum Edition} ', '{edition-Directors Cut} ', '{edition-Final Cut} ', '{edition-International Cut} ', '{edition-Theatrical Cut} ', '{edition-Ultimate Cut} ', '{edition-Alternate Cut} ', '{edition-Coda Cut} ', '{edition-IMAX Enhanced} ', '{edition-IMAX} ', '{edition-Remastered} ', '{edition-Criterion} ', '{edition-Richard Donner} ', '{edition-Black And Chrome} ', '{edition-Definitive} ', '{edition-Ulysses}']

dv = ['DV']
videocodecs = ['VP9', 'x264', 'x265', 'h265', 'h264', 'HEVC']
hdropts = ['HDR10', 'HDR10PLUS']

def createbasevideo(name, resolution):
    target_file=Path(f"{name}.mp4")
    base_image= Path('testpattern.png')
    temp_file=Path(f"tmp.mp4")

    if not target_file.exists():
        print(f"Creating {target_file}...")

        if temp_file.exists():
            temp_file.unlink()

        # --- Construct FFmpeg Command ---
        tmp_cmd = ["ffmpeg"]
        # tmp_cmd.extend(["-loglevel", "quiet"])
        # tmp_cmd.extend(["-stats"])
        tmp_cmd.extend(["-loop", "1"])

        # Add video input
        tmp_cmd.extend(["-i", str(base_image)])

        tmp_cmd.extend(["-c:v", "libx264", "-t", "60", "-pix_fmt", "yuv420p", "-vf", f"scale={resolution}"])

        tmp_cmd.append(str(temp_file))

        # print(f"Generated FFmpeg command:\n{' '.join(tmp_cmd)}\n")

        # --- Execute FFmpeg Command ---
        try:
            # Run the command
            # capture_output=True captures stdout and stderr
            # text=True decodes stdout/stderr as text
            # check=True raises CalledProcessError if the command returns a non-zero exit code
            process = subprocess.run(tmp_cmd, capture_output=True, text=True, check=True)
            print(f"Successfully created '{temp_file}'")

            # Now we have a temp file, add the base audio track

            # --- Construct FFmpeg Command ---
            command = ["ffmpeg"]
            command.extend(["-loglevel", "quiet"])
            command.extend(["-stats"])

            # Add video input
            command.extend(["-i", "tmp.mp4"])

            # Add audio input
            command.extend(["-i", "sounds/1-min-audio.m4a"])
            command.extend(["-c", "copy", "-map", "0:v:0", "-map", "1:a:0"])

            command.append(str(target_file))

            # print(f"Generated FFmpeg command:\n{' '.join(command)}\n")

            # --- Execute FFmpeg Command --
            try:
                # Run the command
                # capture_output=True captures stdout and stderr
                # text=True decodes stdout/stderr as text
                # check=True raises CalledProcessError if the command returns a non-zero exit code
                process = subprocess.run(command, capture_output=True, text=True, check=True)
                print(f"Successfully created '{target_file}'")
            except subprocess.CalledProcessError as e:
                print(f"Error during FFmpeg execution:")
                print(f"Command: {e.cmd}")
                print(f"Exception: {e}")
                print(f"Return Code: {e.returncode}")
                print(f"Stdout: {e.stdout}")
                print(f"Stderr: {e.stderr}")
            except FileNotFoundError:
                print("Error: 'ffmpeg' command not found. Please ensure FFmpeg is installed and in your system's PATH.")
            except Exception as e:
                print(f"An unexpected error occurred: {e}")

            # We have the target file, so clean up the temp file
            temp_file.unlink()

            # print(f"{target_file} created")
            print("===================")

        except subprocess.CalledProcessError as e:
            print(f"Error during FFmpeg execution:")
            print(f"Command: {e.cmd}")
            print(f"Return Code: {e.returncode}")
            print(f"Stdout: {e.stdout}")
            print(f"Stderr: {e.stderr}")
        except FileNotFoundError:
            print("Error: 'ffmpeg' command not found. Please ensure FFmpeg is installed and in your system's PATH.")
        except Exception as e:
            print(f"An unexpected error occurred: {e}")

def create_video_files():
    createbasevideo('240p', '428:240')
    createbasevideo('360p', '640:360')
    createbasevideo('480p', '854:480')
    createbasevideo('576p', '1024:576')
    createbasevideo('720p', '1280:720')
    createbasevideo('1080p', '1920:1080')
    createbasevideo('2160p', '3840:2160')

def ten_percent():
    threshold = 0.10
    return random.random() <= threshold

def get_random_edition ():
    return random.choice(editions)

def change_edition ():
    cur_edition=" "
    if ten_percent():
        cur_edition = get_random_edition()
    return cur_edition

def get_random_dv ():
    return random.choice(dv)

def change_dv ():
    cur_dv=" "
    if ten_percent():
        cur_dv = get_random_dv()
    return cur_dv

def get_random_hdr ():
    return random.choice(hdropts)

def change_hdr ():
    cur_hdr=" "
    if ten_percent():
        cur_hdr = get_random_hdr()
    return cur_hdr

def getrandomsource():
    return random.choice(sources)

def getrandomresolution():
    return random.choice(resolutions)

def getrandomvideocodec():
    return random.choice(videocodecs)
