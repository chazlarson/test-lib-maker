## Builds test libraries for Plex

Work in progress, but the idea is to be able to run a script and dummy up the files you need to test various aspects of Plex, specifically as related to Plex-Meta-Manager.

Currently the script to generate the library for the PMM walkthroughs is available.

### Requirements:
```
 - This is a bash script
```

I do not have a Windows environment available, so have not converted this to Powershell or the like as yet.

#### Install:
```
git clone https://github.com/chazlarson/test-lib-maker.git
```
#### Usage:

```
cd PMM-walkthrough
./walkthrough-library-builder.sh
```

This will:

1. create five base 15-minute testpattern videos in 4k, 1080p, 720p, 576p, and 480p [if they don't already exist]
2. create a directory `test_movie_lib`, which contains 40 movies meeting the requirements listed on the PMM walkthough pages [at time of writing]:

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

All those 40 movies are 15 minutes long; they display a test pattern and play some music.

The "popular" list might be an issue as I imagine there's a fair amount of churn there.

Maybe someday this will grab the list from IMDB.

Create a Movie library in Plex and point it at that folder.  You can move it elsewhere if you want; it's less than 150 MB.

Now proceed with the PMM walkthough.