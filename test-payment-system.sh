#!/bin/bash
# Quick Test Runner for Payment System
# Usage: ./test-payment-system.sh

echo ""
echo "===================================="
echo "Payment System Test Runner"
echo "===================================="
echo ""

# Check if backend is running
echo "[1/3] Checking backend status..."
if curl -s http://localhost:5000/api/health > /dev/null 2>&1; then
    echo "✓ Backend is running"
else
    echo "ERROR: Backend is not running on port 5000"
    echo "Please start backend: cd backend && npm run dev"
    exit 1
fi

# Check if MongoDB is accessible
echo ""
echo "[2/3] Checking MongoDB connection..."
echo "✓ Will be verified by test script"

# Run webhook security tests
echo ""
echo "[3/3] Running webhook security tests..."
echo ""

# Set webhook secret if not already set
if [ -z "$HYPERPAY_WEBHOOK_SECRET" ]; then
    export HYPERPAY_WEBHOOK_SECRET="test-secret-key-change-in-production"
    echo "Using default webhook secret for testing"
fi

# Run the Node.js test script
cd backend
node test-webhook-security.js
TEST_RESULT=$?

if [ $TEST_RESULT -eq 0 ]; then
    echo ""
    echo "===================================="
    echo "✓ ALL TESTS PASSED!"
    echo "===================================="
    echo ""
    echo "Next steps:"
    echo "1. Test payment retry logic manually in mobile app"
    echo "2. Review testing_guide.md for detailed instructions"
    echo "3. Generate production webhook secret before deployment"
    echo ""
else
    echo ""
    echo "===================================="
    echo "✗ SOME TESTS FAILED"
    echo "===================================="
    echo ""
    echo "Please check:"
    echo "1. MongoDB is running"
    echo "2. Test order ID exists in database"
    echo "3. Webhook secret matches .env file"
    echo ""
    echo "See testing_guide.md for troubleshooting"
    echo ""
fi

cd ..
