#!/bin/bash
set -e +o pipefail
# -------------------------------------------------------------------------------------------------
clear_gh_cache() {
local GH_TOKEN=$1
local GH_ONWER=$2
local GH_REPO=$3

while :; do
    JSON_OUTPUT=$(curl \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $GH_TOKEN" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        https://api.github.com/repos/$GH_ONWER/$GH_REPO/actions/caches)

    GH_CACHE_IDS=$(echo "$JSON_OUTPUT" | jq '.actions_caches[] | {id: .id}' | grep "id" | cut -d ':' -f 2 | cut -c 2-)

    # If GH_CACHE_IDS is empty, exit the loop
    if [ -z "$GH_CACHE_IDS" ]; then
        echo "No cache IDs left, end the loop."
        break
    fi

    for GH_CACHE_ID in $GH_CACHE_IDS; do
        echo "Delete Cache-ID: $GH_CACHE_ID"
        curl -L \
            -X DELETE \
            -H "Accept: application/vnd.github+json" \
            -H "Authorization: Bearer $GH_TOKEN" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            https://api.github.com/repos/$GH_ONWER/$GH_REPO/actions/caches/$GH_CACHE_ID
    done

    # Waiting time between iterations to avoid rate limiting
    sleep 5
done
}

# -------------------------------------------------------------------------------------------------
main() {
local GL_GH_TOKEN=<GH_TOKEN>
local GL_GH_ONWER=<GH_ONWER>
clear_gh_cache $GL_GH_TOKEN $GL_GH_ONWER <GH_REPO>
}
# -------------------------------------------------------------------------------------------------

main

