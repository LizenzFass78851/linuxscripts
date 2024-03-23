#!/bin/bash

GH_TOKEN=
GH_ONWER=
GH_REPO=


while :; do
    JSON_OUTPUT=$(curl \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token $GH_TOKEN" \
        https://api.github.com/repos/$GH_ONWER/$GH_REPO/actions/caches)

    GH_CACHE_IDS=$(echo "$JSON_OUTPUT" | jq '.actions_caches[] | {id: .id}' | grep "id" | cut -d ':' -f 2 | cut -c 2-)

    # If GH_CACHE_IDS is empty, exit the loop
    if [ -z "$GH_CACHE_IDS" ]; then
        echo "No cache IDs left, end the loop."
        break
    fi

    for GH_CACHE_ID in $GH_CACHE_IDS; do
        echo "Delete Cache-ID: $GH_CACHE_ID"
        curl \
            -X DELETE \
            -H "Accept: application/vnd.github.v3+json" \
            -H "Authorization: token $GH_TOKEN" \
            https://api.github.com/repos/$GH_ONWER/$GH_REPO/actions/caches/$GH_CACHE_ID
    done

    # Waiting time between iterations to avoid rate limiting
    sleep 5
done

