#!/bin/bash

TOKEN="XXXX"
PROJECT_ID="12"
GITLAB_URL="http://192.168.X.X"

echo "������ Finding all 'created' pipelines (including paginated results)..."

# Function to get all pipeline IDs with pagination
get_all_pipeline_ids() {
  local page=1
  local all_ids=""
  
  while true; do
    echo "  Fetching page $page..."
    
    # Get current page of pipelines
    page_ids=$(curl -s --header "PRIVATE-TOKEN: $TOKEN" \
      "$GITLAB_URL/api/v4/projects/$PROJECT_ID/pipelines?status=created&per_page=100&page=$page" \
      | jq -r '.[] | .id')
    
    # If no results, we're done
    if [ -z "$page_ids" ]; then
      break
    fi
    
    # Add IDs to the list
    all_ids="$all_ids $page_ids"
    
    # Check if we got less than 100 (means it's the last page)
    count=$(echo "$page_ids" | wc -l)
    if [ "$count" -lt 100 ]; then
      break
    fi
    
    page=$((page + 1))
  done
  
  echo "$all_ids"
}

# Get all pipeline IDs
pipeline_ids=$(get_all_pipeline_ids | tr ' ' '\n' | grep -v '^$')

# Count them
total_count=$(echo "$pipeline_ids" | grep -c .)

if [ -z "$pipeline_ids" ] || [ "$total_count" -eq 0 ]; then
  echo "❌ No 'created' pipelines found"
  exit 0
fi

echo ""
echo "������ Found $total_count pipelines with status 'created'"
echo ""
echo "First 10 pipeline IDs:"
echo "$pipeline_ids" | head -10 | while read -r id; do
  echo "  - $id"
done

if [ "$total_count" -gt 10 ]; then
  echo "  ... and $((total_count - 10)) more"
fi

echo ""
read -p "⚠️  Delete ALL $total_count pipelines? (y/N): " confirm

if [[ $confirm != [yY] && $confirm != [yY][eE][sS] ]]; then
  echo "❌ Cancelled"
  exit 0
fi

echo ""
echo "������️  Deleting pipelines..."
deleted=0
failed=0

echo "$pipeline_ids" | while read -r id; do
  if [ -z "$id" ]; then
    continue
  fi
  
  echo -n "  Deleting pipeline #$id... "
  
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
  sleep 0.1
done

echo ""
echo "✅ Complete!"
echo "  ✅ Deleted: $deleted"
echo "  ❌ Failed: $failed"
