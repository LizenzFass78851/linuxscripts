#!/bin/bash


# youtube
## patch apk
java \
  -jar $(ls ./revanced-cli*.jar) patch \
  --patch-bundle $(ls ./revanced-patches*.jar) \
  --exclude swipe-controls \
  --exclude hide-autoplay-button \
  --exclude always-autorepeat \
  --exclude downloads \
  --exclude alternative-thumbnails \
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
  --exclude show-deleted-messages \
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

