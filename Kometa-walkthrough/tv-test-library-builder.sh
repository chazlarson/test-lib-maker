#!/bin/bash

select_random() {
    printf "%s\0" "$@" | shuf -z -n1 | tr -d '\0'
}

docker pull linuxserver/ffmpeg

languages=("afr" "amh" "ara" "ave" "aze" "bak" "bel" "ben" "bis" "bos" "bre" "bul" "cat" "cha" "chi" "chu" "chv" "cor" "cos" "cre" "dan" "dzo" "est" "ewe" "fij" "fin" "fra" "ger" "gla" "gle" "grn" "hat" "hin" "hrv" "hun" "ile" "ind" "ita" "jpn" "kan" "kau" "khm" "kik" "kin" "kon" "lat" "lav" "lim" "lit" "ltz" "lub" "mah" "mal" "mar" "mlg" "mlt" "mon" "ndo" "nep" "nor" "orm" "pan" "phi" "pol" "por" "pus" "rus" "sag" "san" "sin" "sme" "smo" "sna" "snd" "som" "sot" "spa" "srd" "srp" "swe" "tat" "tgk" "tgl" "tha" "tsn" "tur" "twi" "uig" "ukr" "uzb" "ven" "zha")
sources=("Bluray" "Remux" "WEBDL" "WEBRIP" "HDTV" "DVD")
resolutions=("2160p" "1080p" "720p" "576p" "480p" "360p" "240p")
all_audios=("truehd_atmos" "dtsx" "plus_atmos" "dolby_atmos" "truehd" "ma" "flac" "pcm" "hra" "plus" "dtses" "dts" "digital" "aac" "mp3" "opus")
simple_audios=("flac" "aac" "mp3" "opus")

cur_res='2160p'
cur_src='Bluray'
cur_sub1='fra'
cur_sub2='ger'
cur_aud1='bul'
cur_aud2='cat'

get_random_langs () {
    cur_sub1=$(select_random "${languages[@]}")
    cur_sub2=$(select_random "${languages[@]}")
    while [[ "$cur_sub2" == "$cur_sub1" ]]
    do
        cur_sub2=$(select_random "${languages[@]}")
    done

    cur_aud1=$(select_random "${languages[@]}")
    cur_aud2=$(select_random "${languages[@]}")
    while [[ "$cur_aud2" == "$cur_aud1" ]]
    do
        cur_aud2=$(select_random "${languages[@]}")
    done
    echo "subtitle 1: $cur_sub1 subtitle 2: $cur_sub2 audio 1: $cur_aud1 audio 2: $cur_aud2"
}

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
        cur_src='DVD'
    fi
    if [ "$1" = 'DVD' ]
    then
        cur_src='Bluray'
    fi
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
        cur_res='360p'
    fi
    if [ "$1" = '360p' ]
    then
        cur_res='240p'
    fi
    if [ "$1" = '240p' ]
    then
        cur_res='2160p'
    fi
}

getrandomsource () {
    cur_src=$(select_random "${sources[@]}")
}

getrandomresolution () {
    cur_res=$(select_random "${resolutions[@]}")
}

randomizeall () {
    getrandomresolution
    getrandomsource
    get_random_langs
}

startnewshow () {
    getnextresolution $1
    getnextsource $2
    get_random_langs
}

createsubs () {
    cp subs/base.srt subs/sub.eng.srt
    for l in "${languages[@]}"
    do
        FILE="subs/sub.$l.srt"
        if [ -f $FILE ]; then
            echo "File $FILE exists."
        else
            echo "Creating $FILE..."
            cp subs/base.srt subs/sub.$l.srt
        fi
    done
}

createsubs

createaudiofiles () {
    for l in "${languages[@]}"
    do
        for f in "${simple_audios[@]}"
        do
            FILE="1-min-audio-$l.$f"
            if [ -f sounds/$FILE ]; then
                echo "File sounds/$FILE exists."
            else
                echo "Creating $FILE..."
                ffmpeg -y -loglevel quiet -stats -i sounds/1-min-audio.aac -metadata:s:a:0 language=$l sounds/$FILE
            fi
        done
    done
}

createaudiofiles

createbasevideo () {
    FILE="$1.mp4"
    if [ -f $FILE ]; then
        echo "File $FILE exists."
    else
        echo "Creating $FILE..."
        docker run --rm -it -v $(pwd):/config linuxserver/ffmpeg -loglevel quiet -stats -loop 1 -i /config/testpattern.png -c:v libx264 -t 60 -pix_fmt yuv420p -vf scale=$2 /config/tmp.mp4
        docker run --rm -it -v $(pwd):/config linuxserver/ffmpeg -loglevel quiet -stats -i "/config/tmp.mp4" -i /config/sounds/1-min-audio.aac -c copy -map 0:v:0 -map 1:a:0 /config/$FILE
        rm -f tmp.mp4
        echo "$FILE created"
        echo "==================="
    fi
}

createbasevideo '2160p' '3840:2160'
createbasevideo '1080p' '1920:1080'
createbasevideo '720p' '1280:720'
createbasevideo '576p' '1024:576'
createbasevideo '480p' '854:480'
createbasevideo '360p' '640:360'
createbasevideo '240p' '428:240'

# $1 title with year
# $2 id string
# $3 Season number
# $4 episode number
# $5 resolution
# $6 Source

createepisode () {
    mkdir -p "test_tv_lib/$1 $2/Season $3"

    echo "creating episode video file: $1 - S$3E$4 [$cur_src-$cur_res H264 AAC 2.0]-BINGBANG.mkv"

    docker run --rm -it -v $(pwd):/config linuxserver/ffmpeg \
    -y  -loglevel quiet -stats -i "/config/$cur_res.mp4" \
    -i "/config/subs/sub.eng.srt" \
    -i "/config/subs/sub.$cur_sub1.srt" \
    -i "/config/subs/sub.$cur_sub2.srt" \
    -i "/config/sounds/1-min-audio-$cur_aud1.aac" \
    -i "/config/sounds/1-min-audio-$cur_aud2.aac" \
    -c copy \
    -map 0 -dn -map "-0:s" -map "-0:d" \
    -map "1:0" "-metadata:s:s:0" "language=eng" "-metadata:s:s:0" "handler_name=English"  "-metadata:s:s:0" "title=English" \
    -map "2:0" "-metadata:s:s:1" "language=$cur_sub1" "-metadata:s:s:1" "handler_name=$cur_sub1" "-metadata:s:s:1" "title=$cur_sub1" \
    -map "3:0" "-metadata:s:s:2" "language=$cur_sub2" "-metadata:s:s:2" "handler_name=$cur_sub2" "-metadata:s:s:2" "title=$cur_sub2" \
    -map "4:0" "-metadata:s:s:3" "language=$cur_aud1" "-metadata:s:s:2" "handler_name=$cur_aud2" "-metadata:s:s:2" "title=$cur_aud2" \
    -map "5:0" "-metadata:s:s:4" "language=$cur_aud2" "-metadata:s:s:2" "handler_name=$cur_aud2" "-metadata:s:s:2" "title=$cur_aud2" \
    "/config/test_tv_lib/$1 $2/Season $3/$1 - S$3E$4 [$cur_src-$cur_res H264 AAC 2.0]-BINGBANG.mkv"
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

randomizeall
createseason "American Gods (2017)" "{tvdb-253573}" 1 8
createseason "American Gods (2017)" "{tvdb-253573}" 2 8
createseason "American Gods (2017)" "{tvdb-253573}" 3 10
# 8 8 10

startnewshow $cur_res $cur_src
createseason "Bloodline (2015)" "{tvdb-287314}" 1 13
createseason "Bloodline (2015)" "{tvdb-287314}" 2 10
createseason "Bloodline (2015)" "{tvdb-287314}" 3 10
# 13 10 10

startnewshow $cur_res $cur_src
createseason "Breaking Bad (2008)" "{tvdb-81189}" 1 7
createseason "Breaking Bad (2008)" "{tvdb-81189}" 2 13
createseason "Breaking Bad (2008)" "{tvdb-81189}" 3 13
createseason "Breaking Bad (2008)" "{tvdb-81189}" 4 13
createseason "Breaking Bad (2008)" "{tvdb-81189}" 5 16
# 7 13 13 13 16

startnewshow $cur_res $cur_src
createseason "Documentary Now! (2015)" "{tvdb-295697}" 1 7
createseason "Documentary Now! (2015)" "{tvdb-295697}" 2 7
createseason "Documentary Now! (2015)" "{tvdb-295697}" 3 7
createseason "Documentary Now! (2015)" "{tvdb-295697}" 4 6
# 7 7 7 6

randomizeall
createseason "Happy Days (1974)" "{tvdb-74475}"  0  4
randomizeall
createseason "Happy Days (1974)" "{tvdb-74475}"  1 16
randomizeall
createseason "Happy Days (1974)" "{tvdb-74475}"  2 23
randomizeall
createseason "Happy Days (1974)" "{tvdb-74475}"  3 24
randomizeall
createseason "Happy Days (1974)" "{tvdb-74475}"  4 25
randomizeall
createseason "Happy Days (1974)" "{tvdb-74475}"  5 26
randomizeall
createseason "Happy Days (1974)" "{tvdb-74475}"  6 26
randomizeall
createseason "Happy Days (1974)" "{tvdb-74475}"  7 25
randomizeall
createseason "Happy Days (1974)" "{tvdb-74475}"  8 22
randomizeall
createseason "Happy Days (1974)" "{tvdb-74475}"  9 22
randomizeall
createseason "Happy Days (1974)" "{tvdb-74475}" 10 22
randomizeall
createseason "Happy Days (1974)" "{tvdb-74475}" 11 22

startnewshow $cur_res $cur_src
createseason "New Amsterdam (2018)" "{tvdb-349272}" 1 22
createseason "New Amsterdam (2018)" "{tvdb-349272}" 2 18
createseason "New Amsterdam (2018)" "{tvdb-349272}" 3 14
createseason "New Amsterdam (2018)" "{tvdb-349272}" 4 22
createseason "New Amsterdam (2018)" "{tvdb-349272}" 5 13
# 22 18 14 22 13

startnewshow $cur_res $cur_src
createshow "Peaky Blinders (2013)" "{tvdb-270915}" 6 6

startnewshow $cur_res $cur_src
createshow "Picnic at Hanging Rock (2018)" "{tvdb-336473}" 1 6
# 6

startnewshow $cur_res $cur_src
createshow "Squid Game (2021)" "{tvdb-383275}" 1 9
# 9

startnewshow $cur_res $cur_src
createseason "Ted Lasso (2020)" "{tvdb-383203}" 1 10
createseason "Ted Lasso (2020)" "{tvdb-383203}" 2 12
createseason "Ted Lasso (2020)" "{tvdb-383203}" 3 12
# 10 12 12

startnewshow $cur_res $cur_src
createshow "A Touch of Cloth (2012)" "{tvdb-260750}" 2 2
# 2 2

startnewshow $cur_res $cur_src
createseason "Yellowstone (2018)" "{tvdb-341164}" 1 9
createseason "Yellowstone (2018)" "{tvdb-341164}" 2 10
createseason "Yellowstone (2018)" "{tvdb-341164}" 3 10
createseason "Yellowstone (2018)" "{tvdb-341164}" 4 10
createseason "Yellowstone (2018)" "{tvdb-341164}" 5 8
# 9 10 10 10 8
