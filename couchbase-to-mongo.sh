#!/bin/bash

# Couchbase export configuration
CB_HOST="mycouchbasedomain"
CB_BUCKET="whatbucket"
CB_USERNAME="user"
CB_PASSWORD="pass"
CB_EXPORT_FILE="export.json"

# MongoDB import configuration
MONGO_HOST="mymongoconnectionstring"
MONGO_DB="dbname"
MONGO_COLLECTION="collectionname"

# Field mapping
FIELD_MAPPING='{
    "couchbaseField1": "mongodbField1",
    "couchbaseField2": "mongodbField2",
    "couchbaseField3": "mongodbField3"
}'
.
# Export data from Couchbase
cbexport json --cluster=$CB_HOST --bucket=$CB_BUCKET --username=$CB_USERNAME --password=$CB_PASSWORD --format lines --output $CB_EXPORT_FILE

# Check if export was successful
if [ $? -ne 0 ]; then
    echo "Couchbase export failed."
    exit 1
fi

# Perform field mapping on the exported JSON file
jq 'map({mongodbField1: .couchbaseField1, mongodbField2: .couchbaseField2, mongodbField3: .couchbaseField3})' $CB_EXPORT_FILE > mapped_data.json

# Import data into MongoDB
mongoimport --host=$MONGO_HOST --db=$MONGO_DB --collection=$MONGO_COLLECTION --file=mapped_data.json

# Check if import was successful
if [ $? -ne 0 ]; then
    echo "MongoDB import failed."
    exit 1
fi

echo "Data migration from Couchbase to MongoDB completed successfully."
