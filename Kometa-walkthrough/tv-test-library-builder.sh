#!/bin/bash

select_random() {
    printf "%s\0" "$@" | shuf -z -n1 | tr -d '\0'
}

sources=("Bluray" "Remux" "WEBDL" "WEBRIP" "HDTV" "DVD")
resolutions=("2160p" "1080p" "720p" "576p" "480p")

getnextsource () {
    if [ "$1" = 'Bluray' ]
    then
        cur_src='Remux'
    fi
    if [ "$1" = 'Remux' ]
    then
        cur_src='WEBDL'
    fi
    if [ "$1" = 'WEBDL' ]
    then
        cur_src='WEBRIP'
    fi
    if [ "$1" = 'WEBRIP' ]
    then
        cur_src='HDTV'
    fi
    if [ "$1" = 'HDTV' ]
    then
        cur_src='Bluray'
    fi
    echo "switched to $cur_src"
}

getnextresolution () {
    if [ "$1" = '2160p' ]
    then
        cur_res='1080p'
    fi
    if [ "$1" = '1080p' ]
    then
        cur_res='720p'
    fi
    if [ "$1" = '720p' ]
    then
        cur_res='576p'
    fi
    if [ "$1" = '576p' ]
    then
        cur_res='480p'
    fi
    if [ "$1" = '480p' ]
    then
        cur_res='2160p'
    fi
    echo "switched to $cur_res"
}

getrandomsource () {
    cur_src=$(select_random "${sources[@]}")
    echo "switched to $cur_src"
}

getrandomresolution () {
    cur_res=$(select_random "${resolutions[@]}")
    echo "switched to $cur_res"
}

createbasevideo () {
    FILE="$1.mkv"
    if [ -f $FILE ]; then
        echo "File $FILE exists."
    else
        echo "Creating $FILE..."
        docker run --rm -it -v $(pwd):/config linuxserver/ffmpeg -loop 1 -i /config/testpattern.png -c:v libx264 -t 60 -pix_fmt yuv420p -vf scale=$2 /config/$FILE >> ffmpeg.log
        echo "$FILE created"
        echo "==================="
    fi
}

# ffmpeg -y -i input.file -c:v mpeg4 -b:v 868k -tag:v DIVX -s 640x480 -an -pass 1 -f rawvideo /dev/null

createbasevideo '2160p' '3840:2160'
createbasevideo '1080p' '1920:1080'
createbasevideo '720p' '1280:720'
createbasevideo '576p' '1024:576'
createbasevideo '480p' '854:480'

# $1 title with year
# $2 id string
# $3 Season number
# $4 episode number
# $5 resolution
# $6 Source

createepisode () {
    mkdir -p "test_tv_lib/$1 $2/Season $3"

    echo "creating episode video file: $1 - S$3E$4 [$cur_src-$cur_res H264 AAC 2.0]-BINGBANG.mkv"
    docker run --rm -it -v $(pwd):/config linuxserver/ffmpeg  -i "/config/$cur_res.mkv" -i /config/sounds/1-min-audio.m4a -c copy -map 0:v:0 -map 1:a:0 "/config/test_tv_lib/$1 $2/Season $3/$1 - S$3E$4 [$cur_src-$cur_res H264 AAC 2.0]-BINGBANG.mkv" >> ffmpeg.log
}

# $1 title with year
# $2 id string
# $3 Season number
# $4 episode count

createseason () {
    s_num=$(printf "%02d" $3)

    mkdir -p "test_tv_lib/$1 $2/Season $s_num"

    for i in $(seq 1 $4); do 
      e_num=$(printf "%02d" $i)
      createepisode "$1" $2 $s_num $e_num; 
    done

}

# $1 title with year
# $2 TMDB string
# $3 Season count
# $4 Episode count

createshow () {
    mkdir -p "test_tv_lib/$1 $2"

    for i in $(seq 1 $3); do createseason "$1" $2 $i $4; done
}

cur_res='2160p'
cur_src='Bluray'
createseason "American Gods (2017)" "{tvdb-253573}" 1 8
createseason "American Gods (2017)" "{tvdb-253573}" 2 8
createseason "American Gods (2017)" "{tvdb-253573}" 3 10
# 8 8 10

getnextresolution $cur_res
getnextsource $cur_src
createseason "Bloodline (2015)" "{tvdb-287314}" 1 13
createseason "Bloodline (2015)" "{tvdb-287314}" 2 10
createseason "Bloodline (2015)" "{tvdb-287314}" 3 10
# 13 10 10

getnextresolution $cur_res
getnextsource $cur_src
createseason "Breaking Bad (2008)" "{tvdb-81189}" 1 7
createseason "Breaking Bad (2008)" "{tvdb-81189}" 2 13
createseason "Breaking Bad (2008)" "{tvdb-81189}" 3 13
createseason "Breaking Bad (2008)" "{tvdb-81189}" 4 13
createseason "Breaking Bad (2008)" "{tvdb-81189}" 5 16
# 7 13 13 13 16

getnextresolution $cur_res
getnextsource $cur_src
createseason "Documentary Now! (2015)" "{tvdb-295697}" 1 7
createseason "Documentary Now! (2015)" "{tvdb-295697}" 2 7
createseason "Documentary Now! (2015)" "{tvdb-295697}" 3 7
createseason "Documentary Now! (2015)" "{tvdb-295697}" 4 6
# 7 7 7 6

getrandomresolution
getrandomsource
createseason "Happy Days (1974)" "{tvdb-74475}"  0  4
getrandomresolution
getrandomsource
createseason "Happy Days (1974)" "{tvdb-74475}"  1 16
getrandomresolution
getrandomsource
createseason "Happy Days (1974)" "{tvdb-74475}"  2 23
getrandomresolution
getrandomsource
createseason "Happy Days (1974)" "{tvdb-74475}"  3 24
getrandomresolution
getrandomsource
createseason "Happy Days (1974)" "{tvdb-74475}"  4 25
getrandomresolution
getrandomsource
createseason "Happy Days (1974)" "{tvdb-74475}"  5 26
getrandomresolution
getrandomsource
createseason "Happy Days (1974)" "{tvdb-74475}"  6 26
getrandomresolution
getrandomsource
createseason "Happy Days (1974)" "{tvdb-74475}"  7 25
getrandomresolution
getrandomsource
createseason "Happy Days (1974)" "{tvdb-74475}"  8 22
getrandomresolution
getrandomsource
createseason "Happy Days (1974)" "{tvdb-74475}"  9 22
getrandomresolution
getrandomsource
createseason "Happy Days (1974)" "{tvdb-74475}" 10 22
getrandomresolution
getrandomsource
createseason "Happy Days (1974)" "{tvdb-74475}" 11 22

getnextresolution $cur_res
getnextsource $cur_src
createseason "New Amsterdam (2018)" "{tvdb-349272}" 1 22
createseason "New Amsterdam (2018)" "{tvdb-349272}" 2 18
createseason "New Amsterdam (2018)" "{tvdb-349272}" 3 14
createseason "New Amsterdam (2018)" "{tvdb-349272}" 4 22
createseason "New Amsterdam (2018)" "{tvdb-349272}" 5 13
# 22 18 14 22 13

getnextresolution $cur_res
getnextsource $cur_src
createshow "Peaky Blinders (2013)" "{tvdb-270915}" 6 6

getnextresolution $cur_res
getnextsource $cur_src
createshow "Picnic at Hanging Rock (2018)" "{tvdb-336473}" 1 6
# 6

getnextresolution $cur_res
getnextsource $cur_src
createshow "Squid Game (2021)" "{tvdb-383275}" 1 9
# 9

getnextresolution $cur_res
getnextsource $cur_src
createseason "Ted Lasso (2020)" "{tvdb-383203}" 1 10
createseason "Ted Lasso (2020)" "{tvdb-383203}" 2 12
createseason "Ted Lasso (2020)" "{tvdb-383203}" 3 12
# 10 12 12

getnextresolution $cur_res
getnextsource $cur_src
createshow "A Touch of Cloth (2012)" "{tvdb-260750}" 2 2
# 2 2

getnextresolution $cur_res
getnextsource $cur_src
createseason "Yellowstone (2018)" "{tvdb-341164}" 1 9
createseason "Yellowstone (2018)" "{tvdb-341164}" 2 10
createseason "Yellowstone (2018)" "{tvdb-341164}" 3 10
createseason "Yellowstone (2018)" "{tvdb-341164}" 4 10
createseason "Yellowstone (2018)" "{tvdb-341164}" 5 8
# 9 10 10 10 8
