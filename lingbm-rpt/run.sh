#!/bin/bash

# Simple function to echo to stderr
echoerr() { echo "$@" 1>&2; }

for t in `find templates -type f -name '*.txt'`; do
  baseName=`basename "$t"`
  fileName="${baseName%.*}"
  idFile="100/$fileName.ids.txt"

  echoerr "Template: $baseName"

  if [ -f "$idFile" ]; then
    for line in `cat "$idFile" | grep -v '^\s*$'`; do
      rawGraphQl=`ID="$line" envsubst < "$t"`
      graphQl=`echo "$rawGraphQl" | sed 's|@pretty||g' | sed 's|@debug||g'`
      encodedGraphQl=`echo "$graphQl" | jq -Rs`
      echoerr "  $baseName - instantiated with ID: $line"
      curl -X POST 'http://localhost:8642/graphql' -d "{\"query\": $encodedGraphQl }"
    done
  else
    echoerr "  $baseName - no instantiation needed."
    graphQl=`cat "$t" | sed 's|@pretty||g' | sed 's|@debug||g'`
    encodedGraphQl=`echo "$graphQl" | jq -Rs`
    curl -X POST 'http://localhost:8642/graphql' -d "{\"query\": $encodedGraphQl }"
  fi
done



