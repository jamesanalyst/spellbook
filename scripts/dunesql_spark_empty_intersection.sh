#!/bin/bash

set -euo pipefail

res=$(comm -12 <( dbt ls --select resource_type:model --exclude tag:dunesql | sort ) <( dbt ls --exclude resource_type:source --select 1+tag:dunesql+1,resource_type:model | sort ))
if [ -z "$res" ]; then
  exit 0
else
  echo "Common models between DuneSQL and Spark:"
  echo "$res"
  exit 1
fi
