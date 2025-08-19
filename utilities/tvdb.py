import tvdb_v4_official
from utilities.config import Config

def get_tvdb_id(title: str, year: int) -> int | None:
    """
    Finds the TVDB ID for a series using its title and release year.

    Args:
        api_key: Your personal TVDB API key.
        title: The title of the TV series to search for.
        year: The premiere year of the TV series.

    Returns:
        The integer TVDB ID if a match is found, otherwise None.
    """
    try:
        config = Config()

        tvdb = tvdb_v4_official.TVDB(config.get('tvdb.apikey'))

        # Search for the series by its title
        print(f"🔍 Searching for '{title}'...")
        search_results = tvdb.search(title)

        # Filter search results to find the one matching the year
        for series in search_results:
            # The 'year' can sometimes be missing, so we check for its existence
            series_year_str = series.get('year')
            if series_year_str and int(series_year_str) == int(year):
                tvdb_id = int(series['tvdb_id'])
                return tvdb_id

        return None

    except Exception as e:
        print(f"An error occurred: {e}")
        return None

def get_series_info(tvdb_id: int) -> dict | None:
    """
    Fetches detailed information about a TV series from the TVDb API.

    Args:
        tvdb_id: The TVDb ID of the series.

    Returns:
        A dictionary containing the series information, or None if not found.
    """
    try:
        config = Config()

        tvdb = tvdb_v4_official.TVDB(config.get('tvdb.apikey'))

        series_info = tvdb.get_series_extended(tvdb_id)
        return series_info
    except Exception as e:
        print(f"An error occurred: {e}")
        return None

def get_season_info(season_id: int) -> dict | None:
    """
    Fetches detailed information about a specific season of a TV series from the TVDb API.

    Args:
        tvdb_id: The TVDb ID of the series.
        season_number: The season number to fetch information for.

    Returns:
        A dictionary containing the season information, or None if not found.
    """
    try:
        config = Config()

        tvdb = tvdb_v4_official.TVDB(config.get('tvdb.apikey'))

        season_info = tvdb.get_season_extended(season_id)
        return season_info
    except Exception as e:
        print(f"An error occurred: {e}")
        return None
