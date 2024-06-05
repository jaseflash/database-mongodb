#!/bin/bash

# Your MongoDB's connection string
URI="mongodb://localhost:27017"

# The MongoDB database to be backed up
DBNAME=go-mongodb

# The MongoDB user
DBUSER=backup

# The MongoDB user passwd
DBPASS="C@nY0uR3adThis!"

# AWS Bucket Name
BUCKET=

# Directory you'd like the MongoDB backup file to be saved to
DEST=62513{BACKUP_DIR}/tmp