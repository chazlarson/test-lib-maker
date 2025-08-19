from pathlib import Path
import random
import subprocess

def _copy(self, target):
    import shutil
    assert self.is_file()
    shutil.copy(str(self), str(target))  # str() only there for Python < (3, 6)

Path.copy = _copy

# for the randomized audio and subtitle tracks,
# should this script draw form the list of all languages?
# "False" here means use the stock languages,
# which are the ones enabled by default in the language overlays
use_all_languages = False

all_languages = ['ara', 'bul', 'ces', 'chi', 'dan', 'eng', 'fas', 'fra', 'ger', 'hin', 'hun', 'isl', 'ita', 'jpn', 'kor', 'nld', 'nor', 'pol', 'por', 'rus', 'spa', 'swe', 'tel', 'tha', 'tur', 'ukr']
stock_languages = ['eng', 'fra', 'ger', 'jpn', 'por', 'spa']

# for the randomized audio tags,
# should this script draw from the list of all codecs?
# "False" here means use the simple audio list below.
use_all_audio = False

all_audios = ['truehd_atmos', 'dtsx', 'plus_atmos', 'dolby_atmos', 'truehd', 'ma', 'flac', 'pcm', 'hra', 'plus', 'dtses', 'dts', 'digital', 'aac', 'mp3', 'opus']
simple_audios = ['aac']

audiocodecs = ['AAC', 'AAC 1.0', 'AAC 12.0', 'AAC 2.0', 'AAC 24.0', 'AAC 2ch', 'AAC 3.0', 'AAC 4.0', 'AAC 5.0', 'AAC 5.1', 'AAC 6.0', 'AC3 1.0', 'AC3 2.0', 'AC3 2.0ch', 'AC3 2.1', 'AC3 2ch', 'AC3 3.0', 'AC3 3.1', 'AC3 4.0', 'AC3 4.1', 'AC3 5.0', 'AC3 5.1', 'AC3 5.1ch', 'AC3 6.0', 'AC3 7.1', 'AC3 Atmos 2.0', 'AC3 Atmos 3.0', 'AC3 Atmos 5.1', 'AC3 Atmos 7.1', 'AC3 Atmos 8.0', 'ALAC 2.0', 'Atmos 5.1', 'DD 5.1', 'DD2 0 TWA', 'DD5.1', 'DDP', 'DDP 5.1', 'DTS', 'DTS 1.0', 'DTS 2.0', 'DTS 2.1', 'DTS 3.0', 'DTS 4.0', 'DTS 5.0', 'DTS 5.1', 'DTS 6.0', 'DTS 7.1', 'DTS Express 5.1', 'DTS HD MA 5 1', 'DTS LBR 5.1', 'DTS RB', 'DTS-ES 5.1', 'DTS-ES 6.0', 'DTS-ES 6.1', 'DTS-ES 7.1', 'DTS-HD HRA 2.0', 'DTS-HD HRA 5.0', 'DTS-HD HRA 5.1', 'DTS-HD HRA 6.1', 'DTS-HD HRA 7.1', 'DTS-HD HRA 8.0', 'DTS-HD MA 1.0', 'DTS-HD MA 2.0', 'DTS-HD MA 2.1', 'DTS-HD MA 3.0', 'DTS-HD MA 3.1', 'DTS-HD MA 4.0', 'DTS-HD MA 4.1', 'DTS-HD MA 5.0', 'DTS-HD MA 5.1', 'DTS-HD MA 6.0', 'DTS-HD MA 6.1', 'DTS-HD MA 7.1', 'DTS-HD MA 8.0', 'DTS-X 5.1', 'DTS-X 7.1', 'DTS-X 8.0', 'DTSHD-MA 2ch', 'DTSHD-MA 6ch', 'DTSHD-MA 8ch', 'FLAC', 'FLAC 1.0', 'FLAC 2.0', 'FLAC 3.0', 'FLAC 3.1', 'FLAC 4.0', 'FLAC 5.0', 'FLAC 5.1', 'FLAC 6.1', 'FLAC 7.1', 'MP2 1.0', 'MP2 2.0', 'MP3 1.0', 'MP3 2.0', 'MP3 2.0ch', 'MP3 2ch', 'Ogg', 'Opus', 'Opus 1.0', 'Opus 2.0', 'Opus 5.1', 'Opus 7.1', 'PCM 1.0', 'PCM 2.0', 'PCM 2ch', 'PCM 3.0', 'PCM 5.1', 'PCM 6.0', 'TrueHD 1.0', 'TrueHD 2.0', 'TrueHD 3.0', 'TrueHD 3.1', 'TrueHD 5.1', 'TrueHD 6.1', 'TrueHD Atmos 7.1', 'Vorbis 1.0', 'Vorbis 2.0', 'Vorbis 6.0', 'WMA 1.0', 'WMA 2.0', 'WMA 5.1', 'WMA 6.0']

def random_language_array() :
  language_array = []

  while len(language_array) < 5:
    tmp_lang = random.choice(all_languages) if use_all_languages else random.choice(stock_languages)
    if tmp_lang not in language_array:
      language_array.append(tmp_lang)

  return language_array

def create_audio_files():
    from_file=Path('sounds/1-min-audio.m4a')

    for lang in all_languages:
        for audio in simple_audios:
            to_file=Path(f"sounds/1-min-audio-{lang}.{audio}")
            if not to_file.exists():
                # --- Construct FFmpeg Command ---
                command = ["ffmpeg"]
                command.extend(["-loglevel", "quiet", "-y"])

                # Add video input
                command.extend(["-i", str(from_file)])
                command.extend(["-metadata:s:a:0", f"language={lang}"])
                # Set output format to MKV (optional, but good for clarity)
                # command.extend(["-c", "copy"]) # Copy streams without re-encoding for speed
                command.append(str(to_file))

                # --- Execute FFmpeg Command ---
                try:
                    # Run the command
                    # capture_output=True captures stdout and stderr
                    # text=True decodes stdout/stderr as text
                    # check=True raises CalledProcessError if the command returns a non-zero exit code
                    process = subprocess.run(command, capture_output=True, text=True, check=True)
                    print(f"Successfully created '{to_file}'")
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

def create_subtitle_files():
    from_file=Path('subs/base.srt')

    for lang in all_languages:
        to_file=Path(f"subs/sub.{lang}.srt")
        if not to_file.exists():
            from_file.copy(to_file)

def getrandomaudiocodec():
    return random.choice(audiocodecs)
