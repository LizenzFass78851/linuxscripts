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
  -jar $(ls ./revanced-cli*.jar) patch \
  --patches $(ls ./patches-*.rvp) \
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
  --out youtube_revanced.apk \
  "$(ls ./com.google.android.youtube*.apk)"


## sign apk
java \
  -jar apksigner.jar sign \
  --ks "revanced-self-build.keystore" \
  --ks-pass pass:$(cat ./revanced-self-build.password.txt) \
  --out "youtube_revanced_signed.apk" \
  "youtube_revanced.apk"



# twitch
## patch apk
java \
  -jar $(ls ./revanced-cli*.jar) patch \
  --patches $(ls ./patches-*.rvp) \
  $forcemark \
  --disable "Show deleted messages" \
  --out twitch_revanced.apk \
  "$(ls ./tv.twitch.android.app*.apk)"


## sign apk
java \
  -jar apksigner.jar sign \
  --ks "revanced-self-build.keystore" \
  --ks-pass pass:$(cat ./revanced-self-build.password.txt) \
  --out "twitch_revanced_signed.apk" \
  "twitch_revanced.apk"

