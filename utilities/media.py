from imdb import IMDb
from pathlib import Path
from utilities.tvdb import get_series_info, get_season_info
from utilities.paths import build_file_path, build_episode_file_path
from utilities.file_creation import create_video_file
from utilities.exceptions import ComponentNotFoundException, DuplicateTargetException, InvalidLanguageException, Failed

def create_season(series: dict, season: dict, settings: dict, target_path: Path) -> None:
    # create season folder
    target_dir = f"{target_path}/Season{season['number']:02}"

    # get episodes from season
    extended_season = get_season_info(season['id'])

    # for each episode
    for episode in extended_season['episodes']:
        # create the season directory if need be
        Path(target_dir).mkdir(parents=True, exist_ok=True)
        #   get path to episode file
        episode_path = build_episode_file_path(series, episode, target_dir, settings)
        #   create episode file
        create_video_file(episode_path, settings)

def create_series(
    settings: dict,
    series_data: dict
) -> None:
    """
    Creates an MKV video file with multiple audio and subtitle tracks,
    properly tagged with language metadata.

    Args:
    """

    target_dir, file_name = build_file_path(settings, series_data)
    target_path = Path(target_dir)
    # we can ignore the file_name since it's meaningless

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

