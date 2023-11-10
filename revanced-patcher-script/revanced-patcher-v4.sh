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
  --patch-bundle $(ls ./revanced-patches*.jar) \
  $forcemark \
  --exclude "Swipe controls" \
  --exclude "Hide autoplay button" \
  --exclude "Always autorepeat" \
  --exclude "Downloads" \
  --exclude "Alternative thumbnails" \
  --out youtube_revanced.apk \
  --merge $(ls ./revanced-integrations*.apk) \
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
  --patch-bundle $(ls ./revanced-patches*.jar) \
  $forcemark \
  --exclude "Show deleted messages" \
  --out twitch_revanced.apk \
  --merge $(ls ./revanced-integrations*.apk) \
  "$(ls ./tv.twitch.android.app*.apk)"


## sign apk
java \
  -jar apksigner.jar sign \
  --ks "revanced-self-build.keystore" \
  --ks-pass pass:$(cat ./revanced-self-build.password.txt) \
  --out "twitch_revanced_signed.apk" \
  "twitch_revanced.apk"

