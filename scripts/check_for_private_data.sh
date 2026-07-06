#!/bin/bash

# Complete check for private/sensitive information in repository
# Run this before pushing to GitHub

echo "🔍 Checking for private/sensitive information in repository..."
echo

# Check for common personal data patterns
PATTERNS="yourname\|personal\|private\|secret\|password\|username\|login\
 passwd\|token\|key\|credentials\|ssh-\(rsa\|dsa\|ecdsa\|ed25519\)\
 [0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\
 localhost\|my[-_a-z0-9]*\|test[-_a-z0-9]*\|dev[-_a-z0-9]*\
 [A-Z0-9]\{20,\}\\n[A-Za-z0-9+/=]\{20,\}"

# Run checks (excluding this script)
echo "✅ Checking for usernames, passwords, and private strings:"
grep -r -i -E "$PATTERNS" . --exclude="check_for_private_data.sh" --exclude-dir={.git,images,__pycache__} | head -10
if [ $? -eq 0 ]; then
    echo "⚠️  Potential private information found!";
else
    echo "✅ No private string patterns detected."
fi

echo
echo "✅ Checking for serial numbers, MLB, ROM:"
grep -r -E "MLB-[A-Z0-9]{8,}|ROM-[A-Z0-9]{8,}|SystemSerialNumber|SystemUUID" . --exclude-dir={.git,images} --exclude="check_for_private_data.sh" | head -10
if [ $? -eq 0 ]; then
    echo "⚠️  Serial numbers found (should remove or generate new)";
else
    echo "✅ No serial numbers detected."
fi

echo
echo "✅ Checking config.plist for sensitive data:"
grep -r -E "SystemSerialNumber|SystemUUID|MLB|ROM|ProcessorType" EFI/OC/config.plist 2>/dev/null | head -5
echo
echo "✅ Checking Git configuration:"
git config --get user.name
git config --get user.email 2>/dev/null || echo "Git config not set yet"
echo
echo "✅ Private data check complete."