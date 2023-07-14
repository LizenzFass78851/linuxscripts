#!/bin/bash


# youtube
## patch apk
java \
  -jar $(ls ./revanced-cli*.jar) \
  -a "$(ls ./com.google.android.youtube*.apk)" \
  -o youtube_revanced.apk \
  -b $(ls ./revanced-patches*.jar) \
  -m $(ls ./revanced-integrations*.apk) \
  -e swipe-controls \
  -e hide-autoplay-button \
  -e always-autorepeat \
  -e downloads


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
  -jar $(ls ./revanced-cli*.jar) \
  -a "$(ls ./tv.twitch.android.app*.apk)" \
  -o twitch_revanced.apk \
  -b $(ls ./revanced-patches*.jar) \
  -m $(ls ./revanced-integrations*.apk) \
  -e show-deleted-messages \


## sign apk
java \
  -jar apksigner.jar sign \
  --ks "revanced-self-build.keystore" \
  --ks-pass pass:$(cat ./revanced-self-build.password.txt) \
  --out "twitch_revanced_signed.apk" \
  "twitch_revanced.apk"
