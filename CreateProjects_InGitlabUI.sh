#!/bin/bash

# --- Configuration ---
GITLAB_HOST="https://192.168.X.X"
GITLAB_TOKEN="XXXXX"  # REPLACE THIS WITH YOUR TOKEN
# --- End of Configuration ---

# List of project names (from your list)
PROJECTS=(
    "Branch"
    "Caspian"
    "Setad"
    "MobileBank"
    "Fintech"
    "Harim"
    "Beta"
    "InternetBank"
    "WebMobile"
    "Cj"
    "Cj-DigiPay"
    "Pars"
    "Batch_Runner"
    "WebService"
    "Samat"
    "Iban"
    "Top"
    "HubFanavaran"
    "Pol"
    "TelBank"
    "DigitalBank"
    "Switch_Acq"
    "Switch_Iss"
    "Oauth"
    "Bankyar"
    "Asa"
    "HamrahLotus"
    "WebSign"
    "Bourse"
    "WalletHampa"
    "Om"
    "Otp"
    "TopFintech"
    "Vosool"
)

API_URL="${GITLAB_HOST}/api/v4/projects"
TOTAL=${#PROJECTS[@]}
SUCCESS=0
FAILED=0

echo "========================================="
echo "Creating ${TOTAL} projects on ${GITLAB_HOST}"
echo "========================================="
echo ""

for PROJECT_NAME in "${PROJECTS[@]}"
do
    echo "▶ Creating project: ${PROJECT_NAME}"
    
    # Create JSON payload
    JSON_PAYLOAD=$(jq -n \
                      --arg name "$PROJECT_NAME" \
                      --arg visibility "private" \
                      '{name: $name, visibility: $visibility}')
    
    # Send POST request to GitLab API
    RESPONSE=$(curl -s -k -X POST "${API_URL}" \
        --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
        --header "Content-Type: application/json" \
        -d "${JSON_PAYLOAD}" \
        -w "\n%{http_code}")
    
    # Extract HTTP status code (last line)
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | sed '$d')
    
    if [ "$HTTP_CODE" = "201" ]; then
        PROJECT_ID=$(echo "$BODY" | jq -r '.id')
        PROJECT_URL=$(echo "$BODY" | jq -r '.web_url')
        PROJECT_PATH=$(echo "$BODY" | jq -r '.path_with_namespace')
        echo "   ✅ SUCCESS: ${PROJECT_PATH} (ID: ${PROJECT_ID})"
        echo "   ������ URL: ${PROJECT_URL}"
        ((SUCCESS++))
    elif [ "$HTTP_CODE" = "400" ]; then
        ERROR_MSG=$(echo "$BODY" | jq -r '.message | to_entries[0].value[0] // .message // "Unknown error"')
        echo "   ⚠️  ALREADY EXISTS or invalid: ${ERROR_MSG}"
        ((FAILED++))
    else
        ERROR_MSG=$(echo "$BODY" | jq -r '.message // .error // "Unknown error"')
        echo "   ❌ FAILED (HTTP ${HTTP_CODE}): ${ERROR_MSG}"
        ((FAILED++))
    fi
    
    echo ""
done

echo "========================================="
echo "Summary:"
echo "   ✅ Created: ${SUCCESS}"
echo "   ❌ Failed: ${FAILED}"
echo "   ������ Total: ${TOTAL}"
echo "========================================="
