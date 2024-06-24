## Build test libraries for Plex

Work in progress, but the idea is to be able to run a script and dummy up the files you need to test various aspects of Plex, specifically as related to [Kometa](https://kometa.wiki).

Currently the script to generate the library for the Kometa [local](https://kometa.wiki/en/latest/pmm/install/local/) and [docker](https://kometa.wiki/en/latest/pmm/install/docker/) walkthroughs is available.

There is also a tv library script that will generate a TV library with a variety of resolutions and sources; "Happy Days" has randomized sources and resolutions.

### Requirements:

This is a bash script.  It requires bash or a compatible shell.  I do not have a Windows environment available, so have not converted this to Powershell or the like as yet.  PRs welcome.

It uses the ffmpeg Docker image instead of requiring ffmpeg to be installed on the host.  Of course, this means that you need Docker installed.

#### Install:
```
git clone https://github.com/chazlarson/test-lib-maker.git
```
#### Usage:

```
cd Kometa-walkthrough
./walkthrough-library-builder.sh
```

This will:

1. create five base 1-minute testpattern videos in 4k, 1080p, 720p, 576p, and 480p [if they don't already exist]
2. create a directory `test_movie_lib`, which contains a couple hundred movies meeting the requirements listed on the Kometa walkthough pages [at time of writing]:

> For best results with this walkthrough, your test library will contain:
>
> At least two comedy movies released since 2012.
>
> At least two movies from the IMDB top 250.
>
> At least two movies from IMDB's Popular list.
>
> At least two movies from IMDB's Lowest Rated.
>
> A couple different resolutions among the movies.

All those movies are 1 minute long; they display a test pattern and play some music.

They will have random combinations of resolution and source; 10% of them will have a random edition.  They'll all have three audio [english + 2 random languages] and three subtitle [english + 2 random languages] tracks.

The "popular" list might be an issue as I imagine there's a fair amount of churn there. Maybe someday this will grab the list from IMDB.

Create a "Movie" library in Plex and point it at that folder.  You can move it elsewhere if you want; it's not all that big.

Now you have the "small test library" described in the Kometa walkthough.
