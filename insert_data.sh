#!/bin/bash

# Set your AWS region and DynamoDB table name
AWS_REGION="us-east-1"
TABLE_NAME="ddb_usr_dtls"

# Loop to insert 1000 rows
for ((i=1; i<=1000; i++))
do
  # Generate a unique identifier for each row
  ID=$(uuidgen)

  # Generate random data for other attributes (modify as needed)
  FIRST_NAME="FirstName$i"
  LAST_NAME="LastName$i"
  EMAIL="user$i@example.com"
  PHONE_NUMBER="123-456-789$i"

  # Use AWS CLI to insert the item into DynamoDB
  aws dynamodb put-item \
    --region $AWS_REGION \
    --table-name $TABLE_NAME \
    --item \
      '{
        "id": {"S": "'$ID'"},
        "firstName": {"S": "'$FIRST_NAME'"},
        "lastName": {"S": "'$LAST_NAME'"},
        "email": {"S": "'$EMAIL'"},
        "phoneNumber": {"S": "'$PHONE_NUMBER'"}
      }'
  
  echo "Inserted row $i"
done
