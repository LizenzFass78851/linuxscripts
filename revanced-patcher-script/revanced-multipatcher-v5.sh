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
	echo patch $YOUTUBEAPK
	java \
          -jar $(ls ./revanced-cli*.jar) patch \
	  --patches $(ls ./patches-*.rvp) \
	  $forcemark \
	  --disable "Swipe controls" \
	  --disable "Hide autoplay button" \
	  --disable "Always autorepeat" \
	  --disable "Downloads" \
	  --disable "Alternative thumbnails" \
	  --out $(echo $YOUTUBEAPK)_youtube_revanced.apk \
	  "$YOUTUBEAPK"


	## sign apk
	echo sign $YOUTUBEAPK
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
	echo patch $TWITCHAPK
	java \
	  -jar $(ls ./revanced-cli*.jar) patch \
	  --patches $(ls ./patches-*.rvp) \
	  $forcemark \
	  --disable "Show deleted messages" \
	  --out $(echo $TWITCHAPK)_twitch_revanced.apk \
	  "$TWITCHAPK"


	## sign apk
	echo sign $TWITCHAPK
	java \
	  -jar apksigner.jar sign \
	  --ks "revanced-self-build.keystore" \
	  --ks-pass pass:$(cat ./revanced-self-build.password.txt) \
	  --out "$(echo $TWITCHAPK)_twitch_revanced_signed.apk" \
	  "$(echo $TWITCHAPK)_twitch_revanced.apk"
done
