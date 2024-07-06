#!/bin/bash

# ./clean-run.sh

echo deleting base videos:
rm -f 2160p.mp4
rm -f 1080p.mp4
rm -f 720p.mp4
rm -f 576p.mp4
rm -f 480p.mp4
rm -f 360p.mp4
rm -f 240p.mp4

echo deleting sounds:
rm -f sounds/*.aac

echo deleting subs
rm -f subs/sub.*.srt

echo deleting and recreating tv library
rm -fr test_tv_lib/    && ./tv-library-builder.sh

echo deleting and recreating movie library
rm -fr test_movie_lib/ && ./movie-library-builder.sh
