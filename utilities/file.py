"""
File processing and media creation orchestration.

Handles reading input files, parsing media specifications, and orchestrating
the creation of test media files with randomized properties.
"""
from utilities.audio import random_language_array, getrandomaudiocodec
from utilities.video import (
    getrandomresolution, getrandomsource, change_edition,
    getrandomvideocodec, change_dv, change_hdr
)
from utilities.output import show_footer, show_title, is_a_media_line
from utilities.paths import get_random_release_group
from utilities.tvdb import get_tvdb_id
from utilities.media import create_movie, create_series
from utilities.omdb import get_imdb_id_omdb
from utilities.exceptions import (
    ComponentNotFoundException, DuplicateTargetException,
    InvalidLanguageException
)

def randomize_all():
    settings = {}

    settings['resolution'] = getrandomresolution()
    settings['source'] = getrandomsource()
    settings['edition'] = change_edition()
    settings['subtitle_tracks'] = random_language_array()
    settings['audio_tracks'] = random_language_array()

    settings['audio_codec'] = getrandomaudiocodec()
    settings['video_codec'] = getrandomvideocodec()

    settings['dv'] = change_dv()
    settings['hdr'] = change_hdr()

    settings['release_group'] = get_random_release_group()

    print(f"===============================================")
    print(f"resolution:      {settings['resolution']}")
    print(f"source:          {settings['source']}")
    print(f"edition:         {settings['edition']}")
    print(f"subtitle_tracks: {settings['subtitle_tracks']}")
    print(f"audio_tracks:    {settings['audio_tracks']}")
    print(f"audio_codec:     {settings['audio_codec']}")
    print(f"video_codec:     {settings['video_codec']}")
    print(f"dv:              {settings['dv']}")
    print(f"hdr:             {settings['hdr']}")
    print(f"release_group:   {settings['release_group']}")

    return settings

def process_file_line_by_line(filepath, config):
    try:
        with open(filepath, 'r') as file:
            total_count = 0
            completion_count = 0
            section_count = 0
            library_folder = config.get("default_library_folder", "default_library")
            library_type = config.get("default_library_type", "movie")

            for line in file:
                if not line.startswith("#"):
                    if "group" in line:
                        if section_count > 0:
                            show_footer(completion_count, section_count)
                        bits = line.strip().split('|')
                        show_title(bits)
                        section_count = int(bits[2])
                        completion_count = 0
                        # group|Beverly Hills Cop|4
                    elif "library" in line:
                        bits = line.strip().split('|')
                        library_folder = bits[1]
                        library_type = bits[2]
                        # library|ford_test_library|movie
                        print(f"changed library_folder to: {library_folder}")
                        print(f"changed library_type to: {library_type}")
                    else:
                        # Ahsoka|2023|official
                        bits = line.strip().split('|')
                        if is_a_media_line(bits):
                            title = bits[0]
                            year = bits[1]
                            if library_type == 'movie':
                                edition = bits[2] if len(bits) > 2 else None
                                imdb_id = get_imdb_id_omdb(title, year)

                                if imdb_id == None:
                                    print(f"No IMDB ID found for {title} ({year})")
                                    movie_data = None
                                else:
                                    movie_data = {
                                        "title": title,
                                        "year": year,
                                        "edition": edition,
                                        "imdb_id": imdb_id
                                    }

                                if movie_data:
                                    print(f"Creating movie: {movie_data['title']} ({movie_data['year']})")
                                    settings = randomize_all()
                                    settings['library_folder'] = library_folder

                                    # create the movie file
                                    try:
                                        create_movie(settings, movie_data)
                                        completion_count += 1
                                    except DuplicateTargetException:
                                        print(f"Duplicate target directory for {title} ({year}), skipping...")
                                        continue
                                    except ComponentNotFoundException as e:
                                        print(f"Component not found for {title} ({year}): {e}")
                                        continue
                                    except InvalidLanguageException as e:
                                        print(f"Invalid language code for {title} ({year}): {e}")
                                        continue
                                    except Exception as e:
                                        print(f"Error creating movie file for {title} ({year}): {e}")
                                        continue
                                    total_count  += 1

                            else:
                                episode_order = bits[2] if len(bits) > 2 else 'official'
                                tvdb_id = get_tvdb_id(title, year)

                                if tvdb_id == None:
                                    print(f"No TVDB ID found for {title} ({year})")
                                    series_data = None
                                else:
                                    series_data = {
                                        "title": title,
                                        "year": year,
                                        "tvdb_id": tvdb_id,
                                        "episode_order": episode_order
                                    }

                                if series_data:
                                    print(f"Creating series: {series_data['title']} ({series_data['year']})")
                                    settings = randomize_all()
                                    settings['library_folder'] = library_folder

                                    # create the files for the series
                                    try:
                                        create_series(settings, series_data)
                                        completion_count += 1
                                    except DuplicateTargetException:
                                        print(f"Duplicate target directory for {title} ({year}), skipping...")
                                        continue
                                    except ComponentNotFoundException as e:
                                        print(f"Component not found for {title} ({year}): {e}")
                                        continue
                                    except InvalidLanguageException as e:
                                        print(f"Invalid language code for {title} ({year}): {e}")
                                        continue
                                    except Exception as e:
                                        print(f"Error creating movie file for {title} ({year}): {e}")
                                        continue
                                    total_count  += 1

            if section_count > 0:
                show_footer(completion_count, section_count)
                print(f"Total created: {total_count}")

    except FileNotFoundError:
        print(f"Error: The file '{filepath}' was not found.")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

