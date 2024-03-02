#!/bin/bash

# script.sh f
forced=${1:-n}
forcemark=""

if [ "$forced" = "f" ]; then
	forcemark="--force"
fi

# youtube
YOUTUBEAPKS="$(ls ./com.google.android.youtube*.apk)"

## patch apk
for YOUTUBEAPK in ${YOUTUBEAPKS}; do
	java \
	  -jar $(ls ./revanced-cli*.jar) patch \
	  --patch-bundle $(ls ./revanced-patches*.jar) \
	  $forcemark \
	  --exclude "Swipe controls" \
	  --exclude "Hide autoplay button" \
	  --exclude "Always autorepeat" \
	  --exclude "Downloads" \
	  --exclude "Alternative thumbnails" \
	  --out $(echo $YOUTUBEAPK)_youtube_revanced.apk \
	  --merge $(ls ./revanced-integrations*.apk) \
	  "$YOUTUBEAPK"


	## sign apk
	java \
	  -jar apksigner.jar sign \
	  --ks "revanced-self-build.keystore" \
	  --ks-pass pass:$(cat ./revanced-self-build.password.txt) \
	  --out "$(echo $YOUTUBEAPK)_youtube_revanced_signed.apk" \
	  "$(echo $YOUTUBEAPK)_youtube_revanced.apk"
done


# twitch
TWITCHAPKS="$(ls ./tv.twitch.android.app*.apk)"

## patch apk
for TWITCHAPK in ${TWITCHAPKS}; do
	java \
	  -jar $(ls ./revanced-cli*.jar) patch \
	  --patch-bundle $(ls ./revanced-patches*.jar) \
	  $forcemark \
	  --exclude "Show deleted messages" \
	  --out $(echo $TWITCHAPK)_twitch_revanced.apk \
	  --merge $(ls ./revanced-integrations*.apk) \
	  "$TWITCHAPK"


	## sign apk
	java \
	  -jar apksigner.jar sign \
	  --ks "revanced-self-build.keystore" \
	  --ks-pass pass:$(cat ./revanced-self-build.password.txt) \
	  --out "$(echo $TWITCHAPK)_twitch_revanced_signed.apk" \
	  "$(echo $TWITCHAPK)_twitch_revanced.apk"
done
