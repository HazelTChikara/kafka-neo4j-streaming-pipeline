#!/bin/bash

# CSE 511 Project 2 - Submission Package Creator
# This script creates the submission zip file with the required YAML files

echo "======================================"
echo "CSE 511 Project 2 - Submission Creator"
echo "======================================"
echo ""

# Get ASU ID
read -p "Enter your 10-digit ASU ID: " ASU_ID

# Validate ASU ID (should be 10 digits)
if [[ ! $ASU_ID =~ ^[0-9]{10}$ ]]; then
    echo "❌ Error: ASU ID must be exactly 10 digits"
    exit 1
fi

echo ""
echo "Creating submission package: ${ASU_ID}.zip"
echo ""

# Check if required files exist
required_files=(
    "zookeeper-setup.yaml"
    "kafka-setup.yaml"
    "neo4j-values.yaml"
    "kafka-neo4j-connector.yaml"
)

echo "Checking required files..."
all_files_exist=true
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ $file"
    else
        echo "  ✗ $file (MISSING!)"
        all_files_exist=false
    fi
done

if [ "$all_files_exist" = false ]; then
    echo ""
    echo "❌ Error: Some required files are missing!"
    exit 1
fi

echo ""
echo "All required files found!"
echo ""

# Create zip file
zip_file="${ASU_ID}.zip"

# Remove old zip if exists
if [ -f "$zip_file" ]; then
    echo "Removing old submission package..."
    rm "$zip_file"
fi

# Create new zip
echo "Creating zip file..."
zip -q "$zip_file" "${required_files[@]}"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SUCCESS! Submission package created: $zip_file"
    echo ""
    echo "Contents:"
    unzip -l "$zip_file"
    echo ""
    echo "File size: $(du -h "$zip_file" | cut -f1)"
    echo ""
    echo "📤 Ready to submit on Canvas!"
else
    echo ""
    echo "❌ Error creating zip file"
    exit 1
fi

echo ""
echo "======================================"
echo "Submission Checklist:"
echo "======================================"
echo "□ Filename matches your ASU ID"
echo "□ Contains exactly 4 YAML files"
echo "□ No extra files included"
echo "□ Tested with tester.py (100/100)"
echo "□ Ready to upload to Canvas"
echo ""
