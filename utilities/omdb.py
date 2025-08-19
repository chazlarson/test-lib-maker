from imdb import IMDb
import requests
from utilities.config import Config

def get_imdb_id_omdb(title, year):
    """
    Looks up the IMDb ID for a given movie title and year using the OMDb API.

    Args:
        title (str): The title of the movie.
        year (int): The release year of the movie.

    Returns:
        str or None: The IMDb ID (e.g., "tt1234567") if found, otherwise None.
    """
    config = Config()

    base_url = "http://www.omdbapi.com/"
    params = {
        "apikey": config.get('omdb.apikey'),
        "t": title,  # 't' for title search
        "y": year,   # 'y' for year
        "type": "movie" # Ensure we only search for movies
    }

    try:
        response = requests.get(base_url, params=params)
        response.raise_for_status()  # Raise an exception for HTTP errors (4xx or 5xx)
        data = response.json()

        if data.get("Response") == "True":
            # OMDb returns the IMDb ID directly as 'imdbID'
            return data.get("imdbID")
        elif data.get("Response") == "False":
            # OMDb provides an error message if no results are found or other issues
            # print(f"OMDb Error for '{title} ({year})': {data.get('Error')}")
            return None
        else:
            print(f"Unexpected OMDb API response for '{title} ({year})': {data}")
            return None

    except requests.exceptions.RequestException as e:
        print(f"Network or API request error for '{title} ({year})': {e}")
        return None
    except ValueError as e:
        print(f"JSON decoding error for '{title} ({year})': {e}")
        return None
