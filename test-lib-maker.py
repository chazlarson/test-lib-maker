import argparse
from utilities.audio import create_audio_files, create_subtitle_files
from utilities.video import create_video_files
from utilities.file import process_file_line_by_line
from utilities.config import Config

config = Config()

section_count=0

def main():
    """
    The main function of the script.
    """

    parser = argparse.ArgumentParser(
        description="A brief description of your script.",
        epilog="And here's some more text at the end, like an example."
    )

    parser.add_argument(
        "input_file",
        type=str,
        help="The path to the input file (this is a required argument)."
    )

    args = parser.parse_args()

    print(f"Processing input file: {args.input_file}")

    # Set up data files
    create_audio_files(config)
    create_subtitle_files(config)
    create_video_files(config)

    process_file_line_by_line(args.input_file, config)


if __name__ == "__main__":
    main()