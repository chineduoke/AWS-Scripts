#!/bin/bash
# Creates/Updates secrets in AWS Secret manager or Parameter store
# Usage: ./update-secret.sh <environment> <variable-name> <variable-value>
# Example: ./update-secret.sh sandbox DATABASE_PASSWORD "Testing123"

STACK_ENVIRONMENT=$1
VARIABLE_NAME=$2
VARIABLE_VALUE=$3
UAT_REGION=$4
SECRET_MANAGER_VARIABLES=(
GITHUB_OAUTH_TOKEN
SHAREPOINT_CLIENT_SECRET
)
IS_SECRET_MANAGER_VARIABLE="false"

for ITEM in "${SECRET_MANAGER_VARIABLES[@]}"; do
  [[ $VARIABLE_NAME == "$ITEM" ]] && IS_SECRET_MANAGER_VARIABLE="true"
done

if [ "$STACK_ENVIRONMENT" = "sandbox" ]; then
  REGION="ca-central-1"
elif [ "$STACK_ENVIRONMENT" = "staging" ]; then
  REGION="ca-central-1"
elif [ "$STACK_ENVIRONMENT" = "production" ]; then
  REGION="ca-central-1"
else
  echo "Unknown Environment."
  exit 1
fi

if [ "$IS_SECRET_MANAGER_VARIABLE" = "true" ]; then
  aws --profile scc --region $REGION \
    secretsmanager create-secret --name "/${STACK_ENVIRONMENT}/${VARIABLE_NAME}" \
    --secret-string "${VARIABLE_VALUE}"
  aws --profile scc --region $REGION \
    secretsmanager put-secret-value --secret-id "/${STACK_ENVIRONMENT}/${VARIABLE_NAME}" \
    --secret-string "${VARIABLE_VALUE}"
else
  aws --profile scc --region $REGION \
    ssm delete-parameter --name "/${STACK_ENVIRONMENT}/${VARIABLE_NAME}"
  aws --profile scc --region $REGION \
    ssm put-parameter --name "/${STACK_ENVIRONMENT}/${VARIABLE_NAME}" \
    --value "${VARIABLE_VALUE}" \
    --type SecureString \
    --overwrite
fi
