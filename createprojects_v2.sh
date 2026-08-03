#!/bin/bash

# --- Configuration ---
GITLAB_HOST="https://192.168.243.9"
GITLAB_TOKEN="glpat-k0uYhjJ7S2z9g-jgPIOAY286MQp1OjEH.01.0w1tqgt8n"  # REPLACE THIS
GROUP_ID="10"  # REPLACE WITH YOUR LOTUS GROUP ID FROM STEP 1
# --- End of Configuration ---

PROJECTS=(
    "Branch" "Caspian" "Setad" "MobileBank" "Fintech" "Harim"
    "Beta" "InternetBank" "WebMobile" "Cj" "Cj-DigiPay" "Pars"
    "Batch_Runner" "WebService" "Samat" "Iban" "Top" "HubFanavaran"
    "Pol" "TelBank" "DigitalBank" "Switch_Acq" "Switch_Iss" "Oauth"
    "Bankyar" "Asa" "HamrahLotus" "WebSign" "Bourse" "WalletHampa"
    "Om" "Otp" "TopFintech" "Vosool"
)

API_URL="${GITLAB_HOST}/api/v4/projects"
SUCCESS=0
FAILED=0

echo "========================================="
echo "Creating ${#PROJECTS[@]} projects in group: lotus (ID: ${GROUP_ID})"
echo "========================================="
echo ""

for PROJECT_NAME in "${PROJECTS[@]}"
do
    echo "‚ñ∂ Creating project: ${PROJECT_NAME}"
    
    # Create project with namespace_id for lotus group
    JSON_PAYLOAD=$(jq -n \
                      --arg name "$PROJECT_NAME" \
                      --argjson namespace_id "$GROUP_ID" \
                      --arg visibility "private" \
                      '{name: $name, namespace_id: $namespace_id, visibility: $visibility}')
    
    RESPONSE=$(curl -s -k -X POST "${API_URL}" \
        --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
        --header "Content-Type: application/json" \
        -d "${JSON_PAYLOAD}")
    
    if echo "$RESPONSE" | jq -e '.id' > /dev/null; then
        PROJECT_ID=$(echo "$RESPONSE" | jq -r '.id')
        PROJECT_URL=$(echo "$RESPONSE" | jq -r '.web_url')
        PROJECT_PATH=$(echo "$RESPONSE" | jq -r '.path_with_namespace')
        echo "   ‚úÖ SUCCESS: ${PROJECT_PATH} (ID: ${PROJECT_ID})"
        echo "   Ì†ΩÌ¥ó URL: ${PROJECT_URL}"
        ((SUCCESS++))
    else
        ERROR_MSG=$(echo "$RESPONSE" | jq -r '.message // .error // "Unknown error"')
        if echo "$ERROR_MSG" | grep -q "already exists"; then
            echo "   ‚ö†Ô∏è  ALREADY EXISTS: ${PROJECT_NAME}"
        else
            echo "   ‚ùå FAILED: ${ERROR_MSG}"
        fi
        ((FAILED++))
    fi
    echo ""
done

echo "========================================="
echo "Summary:"
echo "   ‚úÖ Created: ${SUCCESS}"
echo "   ‚ùå Failed: ${FAILED}"
echo "   Ì†ΩÌ≥ä Total: ${#PROJECTS[@]}"
echo "========================================="
