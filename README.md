# APIGATEWAY + DYNAMODB (VTL)
In this approach involves a direct integration between API Gateway and DynamoDB, bypassing the need for Lambda functions and Velocity Template Language (VTL) is used to transform and manipulate data within API Gateway itself.

### 1. Create DynamoDB Table:

Lets Create Dynamodb Table with as below
* ddb_usr_dtls is the table name
* phoneNumber is the partition key (HASH).
* email is the sort key (RANGE).
* The GSI named NameIndex is created with firstName as the hash key and lastName as the range key.

```bash
aws dynamodb create-table \
    --table-name ddb_usr_dtls \
    --attribute-definitions \
        AttributeName=phoneNumber,AttributeType=S \
        AttributeName=email,AttributeType=S \
        AttributeName=firstName,AttributeType=S \
        AttributeName=lastName,AttributeType=S \
    --key-schema \
        AttributeName=phoneNumber,KeyType=HASH \
        AttributeName=email,KeyType=RANGE \
    --provisioned-throughput \
        ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --global-secondary-indexes \
        "IndexName=NameIndex,KeySchema=[{AttributeName=firstName,KeyType=HASH},{AttributeName=lastName,KeyType=RANGE}],Projection={ProjectionType=ALL},ProvisionedThroughput={ReadCapacityUnits=5,WriteCapacityUnits=5}"

```
Create a DynamoDB table with a primary key (e.g., "userId").

### 2.Set Up API Gateway:
Create a new API in API Gateway and create a resource with method for each CRUD operation (GET, POST, PUT, DELETE).

### 3. Define Mapping Templates:
For each method in API Gateway, define mapping templates to transform incoming requests and outgoing responses using VTL.


#### POST /users: Create a new user

```VTL
#set($inputRoot = $input.path('$'))
{
  "TableName": "ddb_usr_dtls",
  "Item": {
    "phoneNumber": {
      "S": "$inputRoot.phoneNumber"
    },
    "email": {
      "S": "$inputRoot.email"
    },
    "firstName": {
      "S": "$inputRoot.firstName"
    },
    "lastName": {
      "S": "$inputRoot.lastName"
    }
  }
}

```

#### GET /users/{phoneNumber}/{email}: Get a user by phone number and email

```VTL
#set($inputRoot = $input.path('$'))
{
  "TableName": "ddb_usr_dtls",
  "Key": {
    "phoneNumber": {
      "S": "$input.params('phoneNumber')"
    },
    "email": {
      "S": "$input.params('email')"
    }
  }
}

```

#### PUT /users: Update an existing user

```VTL
#set($inputRoot = $input.path('$'))
{
  "TableName": "ddb_usr_dtls",
  "Key": {
    "phoneNumber": {
      "S": "$inputRoot.phoneNumber"
    },
    "email": {
      "S": "$inputRoot.email"
    }
  },
  "UpdateExpression": "SET firstName = :firstName, lastName = :lastName",
  "ExpressionAttributeValues": {
    ":firstName": {
      "S": "$inputRoot.firstName"
    },
    ":lastName": {
      "S": "$inputRoot.lastName"
    }
  }
}

```
#### DELETE /users/{phoneNumber}/{email}: Delete a user by phone number and email

```VTL
#set($inputRoot = $input.path('$'))
{
  "TableName": "ddb_usr_dtls",
  "Key": {
    "phoneNumber": {
      "S": "$input.params('phoneNumber')"
    },
    "email": {
      "S": "$input.params('email')"
    }
  }
}

```
#### Search by GSI

GET /users?firstName=Arun&lastName=Kumar <br>

```VTL
#set($inputRoot = $input.path('$'))
{
  "TableName": "ddb_usr_dtls",
  "IndexName": "NameIndex",
  "KeyConditionExpression": "firstName = :firstName AND lastName = :lastName",
  "ExpressionAttributeValues": {
    ":firstName":{"S": "$input.params('firstName')"},
    ":lastName":{"S": "$input.params('lastName')"}
  }
}

```

To insert 1000 rows into a DynamoDB table using the AWS CLI, you can create a Bash script. The script will make use of the aws dynamodb put-item command to insert each row. Below is an example Bash script:
```bash
#!/bin/bash

# Set your AWS region and DynamoDB table name
AWS_REGION="us-east-1"
TABLE_NAME="ddb_usr_dtls"

# Loop to insert 1000 rows
for ((i=1; i<=1000; i++))
do
  
  ID="$i"

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

```