#!/bin/bash

# Navigate to the api directory
cd "$(dirname "$0")"

echo "--- Drink & Deryve Backend Setup ---"

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
fi

# Run the seed script
echo "Step 1: Seeding the database..."
node seed.js

# Start the Express API
echo "Step 2: Starting the Express API..."
npm start
