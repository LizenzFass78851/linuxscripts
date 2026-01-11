#!/bin/bash

# script.sh f
forced=${1:-n}
forcemark=""

if [ "$forced" = "f" ]; then
	forcemark="--force"
fi

# youtube
## patch apk
java \
  -jar $(ls ./morphe-cli*.jar) patch \
  --patches $(ls ./patches-*.mpp) \
  $forcemark \
  --disable "Swipe controls" \
  --disable "Hide autoplay button" \
  --disable "Always repeat" \
  --disable "Downloads" \
  --disable "Alternative thumbnails" \
  --enable "Custom branding" \
  --enable "Custom branding icon for YouTube" \
  --options=appIcon=afn_blue \
  --enable "Custom branding name for YouTube" \
  --out youtube_morphe.apk \
  "$(ls ./com.google.android.youtube*.apk)"


## sign apk
java \
  -jar apksigner.jar sign \
  --ks "morphe-self-build.keystore" \
  --ks-pass pass:$(cat ./morphe-self-build.password.txt) \
  --out "youtube_morphe_signed.apk" \
  "youtube_morphe.apk"

