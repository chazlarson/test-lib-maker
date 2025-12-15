## Build test libraries for Plex

Work in progress, but the idea is to be able to run a script and dummy up the files you need to test various aspects of Plex, specifically as related to [Kometa](https://kometa.wiki).

### Config.yaml

```yaml
tvdb:
  apikey: YOUR_API_KEY_HERE
    # Enter TVDb API Key (REQUIRED)
    # get an API key here: https://www.thetvdb.com/api-information

omdb:
  apikey: YOUR_API_KEY_HERE
    # Enter OMDb API Key (REQUIRED)
    # Get your free API key from: http://www.omdbapi.com/apikey.aspx

default_library_folder: test_movie_library
default_library_type: movie
  # If no library or type is specified in the input file these are the defaults

all_languages: false
  # Set this to true to use a larger set of languages rather than the
  # set of six corresponding to Kometa's default language overlays
  # using more than the six will require Kometa config changes.
  # The larger list comprises the first twenty in the list in the Kometa wiki.
```

### Input file format

There are two input file examples provided:

`movie_list.txt` which contains 247 movies.

`series_list.txt` which contains 47 series.

These are separated just for clarity.  You can combine both in one file.

There are four recognized "line formats" in these files.

#### library line:
```
library|test_movie_library|movie
```
This line defines the library name and type.  The script will put the fake movies in a folder with the name, and every media line that follows will be interpreted as if it's this type, until another `library` line is hit.

#### group line:
```
group|Test Movie Library|247
```
This optional line defines a group by name and count; it is used purely for cosmetics in the output and tracking how many of the expected items were created.

#### media line:
There are two types, one for movies and one for series. at this point they differ only in what the third field means.

Movie:
```
Title|Year|Edition
```
`Edition` is optional.  If it's not present, there is a 10% chance that the movie will be assigned a random edition.

Examples:
```
Alarum|2025
Alien Romulus|2024|Extended
Alien|1979|Director's Cut
```

Series:
```
Title|Year|Episode Order
```
`Episode Order` is optional and can be set to one of:

| Value     | Meaning               |
|-----------|-----------------------|
| official  | Aired Order [default] |
| dvd       | DVD Order             |
| absolute  | Absolute Order        |
| alternate | Alternate Order       |
| regional  | Regional Order        |
| altdvd    | Alternate DVD Order   |
| alttwo    | Alternate Order 2     |

Not all series have all these orders.

Examples:
```
A Touch of Cloth|2012|absolute
American Gods|2017
Bad Monkey|2024|dvd
```

### Example file and output:

`movie-example.txt`:
```
library|scifi_library|movie

group|Alien Movies|7
Alien|1979
Aliens|1986
Alien 3|1992
Alien: Resurrection|1997
Prometheus|2012
Alien: Covenant|2017
Alien: Romulus|2024

group|Matrix Movies|5
The Matrix|1999
The Matrix Reloaded|2003
The Animatrix|2003
The Matrix Revolutions|2003
The Matrix Resurrections|2021
```

Output:
```
Processing input file: movie-example.txt
changed library_folder to: scifi_library
changed library_type to: movie
===============================================
Creating 7 items for Alien Movies
===============================================
Successfully created 'scifi_library/Alien (1979) {imdb-tt0078748}/Alien (1979) {imdb-tt0078748} [WEBDL-2160p h264 DTS]-MARK.mkv'
Successfully created 'scifi_library/Aliens (1986) {imdb-tt0090605}/Aliens (1986) {imdb-tt0090605} [DVD-360p x264 Opus 7.1]-EDPH.mkv'
Successfully created 'scifi_library/Alien 3 (1992) {imdb-tt0349773}/Alien 3 (1992) {imdb-tt0349773} [DVD-576p x264 PCM 5.1]-TAGWEB.mkv'
Successfully created 'scifi_library/Alien Resurrection (1997) {imdb-tt0118583}/Alien Resurrection (1997) {imdb-tt0118583} [WEBRIP-240p x265 DV Opus 7.1]-AlteZachen.mkv'
Successfully created 'scifi_library/Prometheus (2012) {imdb-tt1446714}/Prometheus (2012) {imdb-tt1446714} [DVD-1080p VP9 DTS 2.1]-HiGH.mkv'
Successfully created 'scifi_library/Alien Covenant (2017) {imdb-tt2316204}/Alien Covenant (2017) {imdb-tt2316204} [WEBRIP-720p HEVC Ogg]-HEHEHE.mkv'
Successfully created 'scifi_library/Alien Romulus (2024) {imdb-tt18412256}/Alien Romulus (2024) {imdb-tt18412256} [DVD-480p x264 DTS-HD HRA 5.0]-PiA.mkv'
===============================================
Created 7 items of expected 7
===============================================
===============================================
Creating 5 items for Matrix Movies
===============================================
Successfully created 'scifi_library/The Matrix (1999) {imdb-tt0133093} {edition-Theatrical Cut}/The Matrix (1999) {imdb-tt0133093} {edition-Theatrical Cut} [HDTV-576p h264 DTS Express 5.1]-PineapplePizza.mkv'
Successfully created 'scifi_library/The Matrix Reloaded (2003) {imdb-tt0234215}/The Matrix Reloaded (2003) {imdb-tt0234215} [WEBRIP-1080p h264 HDR10 DTS 1.0]-SkilledMelodicSparrowFromHyperborea.mkv'
Successfully created 'scifi_library/The Animatrix (2003) {imdb-tt5700244}/The Animatrix (2003) {imdb-tt5700244} [Bluray-576p x265 DV MP3 2ch]-TTT.mkv'
Successfully created 'scifi_library/The Matrix Revolutions (2003) {imdb-tt0242653}/The Matrix Revolutions (2003) {imdb-tt0242653} [WEBRIP-720p VP9 DV DTS-HD MA 6.1]-saMMie.mkv'
Successfully created 'scifi_library/The Matrix Resurrections (2021) {imdb-tt10838180}/The Matrix Resurrections (2021) {imdb-tt10838180} [HDTV-1080p h264 AC3 1.0]-IFCKINGLOVENF.mkv'
===============================================
Created 5 items of expected 5
===============================================
Total created: 12
```
One out of the twelve got a random edition due to the 10% die roll.

Combined example:
```
library|scifi_movie_library|movie

group|Alien Movies|7
Alien|1979
Aliens|1986
Alien 3|1992
Alien: Resurrection|1997
Prometheus|2012
Alien: Covenant|2017
Alien: Romulus|2024

group|Matrix Movies|5
The Matrix|1999
The Matrix Reloaded|2003
The Animatrix|2003
The Matrix Revolutions|2003
The Matrix Resurrections|2021

library|scifi_tv_library|shows

group|Star Trek|12
Star Trek: Deep Space Nine|1993
Star Trek: Discovery|2017
Star Trek: Enterprise|2001
Star Trek: Lower Decks|2020
Star Trek: Picard|2020
Star Trek: Prodigy|2021
Star Trek: Short Treks|2018
Star Trek: Strange New Worlds|2022
Star Trek: The Animated Series|1973
Star Trek: The Next Generation|1987
Star Trek: Voyager|1995
Star Trek|1966

group|Walking Dead|5
The Walking Dead: Daryl Dixon|2023
The Walking Dead: Dead City|2023
The Walking Dead: The Ones Who Live|2024
The Walking Dead: World Beyond|2020
The Walking Dead|2010
```

### Output file details

All video files contain English audio and subtitles along with two more audio and subtitle tracks in random languages [from the set of 6 languages that Kometa applies overlays for by default; ("fra" "ger" "jpn" "por" "spa")].

### Requirements:

This is a Python script.  It should run under any release of Python 3.

It uses the ffmpeg Docker image instead of requiring ffmpeg to be installed on the host.  Of course, this means that you need Docker installed.

### Setup:

1. clone the repo

2. install requirements

    ```
    python -m pip install -r requirements.txt
    ```

3. create a config file

    copy `config.yaml.template` to `config.yaml` then edit it to add the requied keys [two at this point]:

    ```yaml
    tvdb:
      apikey: YOUR_API_KEY_HERE
        # Enter TVDb API Key (REQUIRED)

    omdb:
      apikey: YOUR_API_KEY_HERE
        # Enter OMDb API Key (REQUIRED)
        # Get your free API key from: http://www.omdbapi.com/apikey.aspx

    default_library_folder: test_movie_library
    default_library_type: movie

    all_languages: false
    ```

### Usage:

```
python test-lib-maker.py some_file.txt
```

Where `some_file.txt` is a text file following the format shown above.

All movies and episodes are 1 minute long; they display a test pattern and play some music.

They will have random combinations of resolution and source; 10% of them will have a random edition.  They'll all have three audio [english + 2 random languages] and three subtitle [english + 2 random languages] tracks.

Once complete, create a "Movie" or "TV Shows" library (as appropriate) in Plex and point it at the folder full of generated files.  You can move it elsewhere if you want; it's not all that big.

Now you have the "small test library" described in the Kometa walkthough.

Planned [in no particular order]:
1. make the files "real" with the actual codecs and whatnot.
2. directly support online lists [trakt/mdb/imdb/letterboxd]
