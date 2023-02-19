#!/bin/bash

## patch apk
java \
  -jar $(ls ./revanced-cli*.jar) \
  -a "$(ls ./com.google.android.youtube*.apk)" \
  -o revanced.apk \
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
  --out "revanced_signed.apk" \
  "revanced.apk"
