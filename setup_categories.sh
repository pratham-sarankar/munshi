#!/bin/bash

# Categories Feature Setup Script
# This script sets up the categories feature by generating the required Drift database files

echo "🚀 Setting up Categories Feature..."
echo ""

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo "Please install Flutter from https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✓ Flutter found"
echo ""

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Generate Drift database files
echo "🔨 Generating Drift database files..."
flutter pub run build_runner build --delete-conflicting-outputs

# Check if generation was successful
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Categories feature setup complete!"
    echo ""
    echo "You can now:"
    echo "  1. Run the app: flutter run"
    echo "  2. Navigate to the Categories tab"
    echo "  3. Add, edit, or delete categories"
    echo ""
else
    echo ""
    echo "❌ Code generation failed"
    echo "Please check the error messages above"
    exit 1
fi
