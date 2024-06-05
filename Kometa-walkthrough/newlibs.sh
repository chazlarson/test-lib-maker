#!/bin/bash

# ./newlibs.sh /path/to/media plex_token
#  i.e.
# ./newlibs.sh /opt/kometa-plex/media 2PxWuxX_WHIZBANGt3Z2

rm -fr test_tv_lib/    && ./tv-test-library-builder.sh     && rm -fr "$1/test_tv_lib/"    && rsync -av --progress test_tv_lib "$1/"
rm -fr test_movie_lib/ && ./walkthrough-library-builder.sh && rm -fr "$1/test_movie_lib/" && rsync -av --progress test_movie_lib "$1/"

curl -fLv http://192.168.1.11:32400/library/sections/all/refresh?X-Plex-Token=$2
