#!/bin/bash

TOKEN="glpat-z_k3smStFg5U9-PyeKOl0G86MQp1OjEH.01.0w1un828g"
PROJECT_ID="12"
GITLAB_URL="http://192.168.251.219"

# Define which statuses to delete
# Available statuses: created, pending, running, failed, success, canceled, skipped, manual, scheduled
STATUSES=("created" "pending" "running" "failed" "success" "canceled")

echo "������ Finding pipelines with statuses: ${STATUSES[*]}"
echo ""

# Function to get all pipeline IDs for a specific status
get_pipeline_ids() {
  local status=$1
  local page=1
  local all_ids=""
  
  while true; do
    # Fetch current page
    page_ids=$(curl -s --header "PRIVATE-TOKEN: $TOKEN" \
      "$GITLAB_URL/api/v4/projects/$PROJECT_ID/pipelines?status=$status&per_page=100&page=$page" \
      | jq -r '.[] | .id')
    
    # If no results, break
    if [ -z "$page_ids" ]; then
      break
    fi
    
    all_ids="$all_ids $page_ids"
    
    # Check if this is the last page
    count=$(echo "$page_ids" | wc -l)
    if [ "$count" -lt 100 ]; then
      break
    fi
    
    page=$((page + 1))
  done
  
  echo "$all_ids"
}

# Collect all pipeline IDs by status
declare -A status_pipelines
total_all=0

for status in "${STATUSES[@]}"; do
  echo "  Checking status: $status..."
  ids=$(get_pipeline_ids "$status")
  
  # Remove extra spaces and count
  ids_clean=$(echo "$ids" | tr ' ' '\n' | grep -v '^$')
  count=$(echo "$ids_clean" | grep -c . 2>/dev/null || echo 0)
  
  if [ "$count" -gt 0 ]; then
    status_pipelines["$status"]="$ids_clean"
    echo "    ✅ Found $count pipelines with status '$status'"
    total_all=$((total_all + count))
  else
    echo "    ℹ️  No pipelines with status '$status'"
  fi
done

echo ""
echo "������ Total pipelines found: $total_all"

if [ "$total_all" -eq 0 ]; then
  echo "❌ No pipelines found with any of the specified statuses"
  exit 0
fi

# Show summary of what will be deleted
echo ""
echo "������ Summary of pipelines to delete:"
for status in "${STATUSES[@]}"; do
  if [ -n "${status_pipelines[$status]}" ]; then
    count=$(echo "${status_pipelines[$status]}" | grep -c .)
    echo "  - $status: $count pipeline(s)"
  fi
done

echo ""
read -p "⚠️  Delete ALL $total_all pipelines? (y/N): " confirm

if [[ $confirm != [yY] && $confirm != [yY][eE][sS] ]]; then
  echo "❌ Cancelled"
  exit 0
fi

echo ""
echo "������️  Deleting pipelines..."
deleted=0
failed=0

# Delete all pipelines
for status in "${STATUSES[@]}"; do
  if [ -z "${status_pipelines[$status]}" ]; then
    continue
  fi
  
  echo ""
  echo "  ������ Deleting $status pipelines..."
  
  echo "${status_pipelines[$status]}" | while read -r id; do
    if [ -z "$id" ]; then
      continue
    fi
    
    echo -n "    Deleting pipeline #$id ($status)... "
    
    response=$(curl -s -o /dev/null -w "%{http_code}" \
      --request DELETE \
      --header "PRIVATE-TOKEN: $TOKEN" \
      "$GITLAB_URL/api/v4/projects/$PROJECT_ID/pipelines/$id")
    
    if [ "$response" -eq 204 ]; then
      echo "✅ Done"
      deleted=$((deleted + 1))
    else
      echo "❌ Failed (HTTP $response)"
      failed=$((failed + 1))
    fi
    
    # Small delay to avoid rate limiting
    sleep 0.05
  done
done

echo ""
echo "✅ Complete!"
echo "  ✅ Deleted: $deleted"
echo "  ❌ Failed: $failed"
