"""
Movie and TV series media creation.

Orchestrates the creation of test movie and TV series files with proper
directory structures and metadata.
"""
import os
from pathlib import Path
from utilities.tvdb import get_series_info, get_season_info
from utilities.paths import build_file_path, build_episode_file_path
from utilities.file_creation import create_video_file
from utilities.exceptions import DuplicateTargetException

def create_season(series: dict, season: dict, settings: dict, target_path: Path) -> None:
    # create season folder
    target_dir = f"{target_path}/Season{season['number']:02}"

    # get episodes from season
    extended_season = get_season_info(season['id'])

    if extended_season is None:
        print(f"Season {season['number']} is None, skipping...")
        return
    
    index = 0
    # for each episode
    for episode in extended_season['episodes']:
        index += 1
        se_str = f"S{episode['seasonNumber']:02}E{episode['number']:02}"
        print(f"Processing episode {index} - {se_str}")
        if index == 87:
            print("I'm about to fail again")
        # create the season directory if need be
        Path(target_dir).mkdir(parents=True, exist_ok=True)
        #   get path to episode file
        episode_path = build_episode_file_path(
            series, episode, target_dir, settings
        )
        if os.path.exists(episode_path):
            print(f"{series['name']} - {se_str} already exists, skipping...")
            continue

        #   create episode file
        create_video_file(episode_path, settings)

    print(f"Done with season {season['number']}")


def create_series(
    settings: dict,
    series_data: dict
) -> None:
    """
    Creates an MKV video file with multiple audio and subtitle tracks,
    properly tagged with language metadata.

    Args:
    """

    target_dir, _ = build_file_path(settings, series_data)
    target_path = Path(target_dir)

    series = get_series_info(series_data['tvdb_id'])

    is_empty = not any(target_path.iterdir())

    if target_path.exists() and not is_empty:
        raise DuplicateTargetException(f"Target directory '{target_dir}' already exists and is not empty.")

    # now I need to loop through the series and create the folders and files
    # for each season
    seasons = series['seasons']

    for season in seasons:
        if 'type' in season and 'type' in season['type'] and season['type']['type'] == series_data['episode_order']:
            create_season(series, season, settings, target_path)

def create_movie(
    settings: dict,
    movie_data: dict
) -> None:

    target_dir, file_name = build_file_path(settings, movie_data)
    target_path = Path(target_dir)

    is_empty = not any(target_path.iterdir())

    if target_path.exists() and not is_empty:
        raise DuplicateTargetException(f"Target directory '{target_dir}' already exists and is not empty.")

    create_video_file(f"{target_path}/{file_name}", settings)
