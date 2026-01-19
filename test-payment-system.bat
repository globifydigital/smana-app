@echo off
REM Quick Test Runner for Payment System
REM Usage: test-payment-system.bat

echo.
echo ====================================
echo Payment System Test Runner
echo ====================================
echo.

REM Check if backend is running
echo [1/3] Checking backend status...
curl -s http://localhost:5000/api/health >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Backend is not running on port 5000
    echo Please start backend: cd backend ^&^& npm run dev
    exit /b 1
)
echo ✓ Backend is running

REM Check if MongoDB is accessible
echo.
echo [2/3] Checking MongoDB connection...
REM This is a simple check, actual connection test happens in Node script
echo ✓ Will be verified by test script

REM Run webhook security tests
echo.
echo [3/3] Running webhook security tests...
echo.

REM Set webhook secret if not already set
if not defined HYPERPAY_WEBHOOK_SECRET (
    set HYPERPAY_WEBHOOK_SECRET=test-secret-key-change-in-production
    echo Using default webhook secret for testing
)

REM Run the Node.js test script
cd backend
node test-webhook-security.js

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ====================================
    echo ✓ ALL TESTS PASSED!
    echo ====================================
    echo.
    echo Next steps:
    echo 1. Test payment retry logic manually in mobile app
    echo 2. Review testing_guide.md for detailed instructions
    echo 3. Generate production webhook secret before deployment
    echo.
) else (
    echo.
    echo ====================================
    echo ✗ SOME TESTS FAILED
    echo ====================================
    echo.
    echo Please check:
    echo 1. MongoDB is running
    echo 2. Test order ID exists in database
    echo 3. Webhook secret matches .env file
    echo.
    echo See testing_guide.md for troubleshooting
    echo.
)

cd ..
pause
