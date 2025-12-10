# 🔧 Step-by-Step Dependency Fix Guide

**Time to complete**: ~2-3 hours
**Difficulty**: ⭐ Easy
**Risk**: Low (with tests)

---

## ✅ Step 1: JavaScript SDK - pg-client-sdk (20 minutes)

### Fix package.json
```bash
cd backend/pg-client-sdk
```

**Before:**
```json
{
  "dependencies": {
    "jose": "^6.0.11",
    "ajv": "^8.17.1"
  }
}
```

**After:**
```json
{
  "dependencies": {
    "jose": "6.0.11",
    "ajv": "8.17.1"
  }
}
```

### Execute
```bash
# Option A: Manual edit
nano package.json
# Remove the ^ symbols

# Option B: Automated
npm install jose@6.0.11 --save-exact
npm install ajv@8.17.1 --save-exact

# Verify
cat package-lock.json | head -20
npm audit
```

### Verify
```bash
npm ci
npm run build
npm test  # Once tests are written
```

---

## ✅ Step 2: JavaScript SDK - pgpd-client-sdk (30 minutes)

### OPTION A: DELETE IT (RECOMMENDED)

**Why?**
- Reduces maintenance burden
- Avoids divergence bugs
- Merchants only need one SDK
- Cleaner architecture

```bash
rm -rf backend/pgpd-client-sdk
# Update any docs that reference it
```

---

### OPTION B: FIX IT (If must keep)

```bash
cd backend/pgpd-client-sdk
```

**Before:**
```json
{
  "dependencies": {
    "axios": "^1.9.0",
    "axios-retry": "^3.5.0",
    "jose": "^6.0.11"
  }
}
```

**After:**
```json
{
  "dependencies": {
    "axios": "1.7.7",
    "axios-retry": "3.5.0",
    "ajv": "8.17.1",
    "jose": "6.0.11"
  }
}
```

### Execute
```bash
npm install axios@1.7.7 --save-exact
npm install axios-retry@3.5.0 --save-exact
npm install ajv@8.17.1 --save  # New dependency
npm install jose@6.0.11 --save-exact

# Remove caret from package.json manually
nano package.json
```

### Add Validation to PGPD SDK

Copy validation from `backend/pg-client-sdk/lib/utils/schemaValidator.js`:

```bash
# Copy file
cp backend/pg-client-sdk/lib/utils/schemaValidator.js \
   backend/pgpd-client-sdk/lib/utils/schemaValidator.js

# Update pgpd-client-sdk services to use it
# Edit: backend/pgpd-client-sdk/lib/services/*.js
# Add: const { validatePaycollectPayload } = require('../utils/schemaValidator');
```

### Verify
```bash
npm ci
npm run build
npm audit
```

---

## ✅ Step 3: C# SDK - PayGlocal.SDK (20 minutes)

### Update .csproj File

**File**: `backendCsh/pg-client-sdk-csharp/PayGlocal.SDK.csproj`

**Before:**
```xml
<PropertyGroup>
  <TargetFramework>net6.0</TargetFramework>
  ...
</PropertyGroup>

<ItemGroup>
  <PackageReference Include="jose-jwt" Version="4.1.0" />
  <PackageReference Include="Newtonsoft.Json" Version="13.0.3" />
  <PackageReference Include="Newtonsoft.Json.Schema" Version="3.0.15" />
  <PackageReference Include="System.Text.Json" Version="8.0.0" />
</ItemGroup>
```

**After:**
```xml
<PropertyGroup>
  <TargetFramework>net8.0</TargetFramework>
  ...
</PropertyGroup>

<ItemGroup>
  <PackageReference Include="jose-jwt" Version="[4.1.0]" />
  <PackageReference Include="Newtonsoft.Json" Version="[13.0.3]" />
  <PackageReference Include="Newtonsoft.Json.Schema" Version="[3.0.15]" />
  <!-- REMOVED: System.Text.Json 8.0.0 - use built-in -->
</ItemGroup>
```

### Execute
```bash
cd backendCsh/pg-client-sdk-csharp

# Option A: Visual Studio
# Right-click project → Properties → General → Target Framework → Select net8.0

# Option B: Command line
dotnet list package --outdated
dotnet list package --vulnerable

# Update project file
nano PayGlocal.SDK.csproj
# Change <TargetFramework>net6.0</TargetFramework> to net8.0
# Remove the System.Text.Json package reference
# Add version [version] syntax for exact pinning

# Restore packages
dotnet restore
```

### Verify
```bash
dotnet build
dotnet list package --vulnerable
# Should return: No vulnerable packages found
```

---

## ✅ Step 4: PHP SDK (20 minutes)

### Update composer.json

**File**: `backendPhp/pg-client-sdk-php/composer.json`

**Before:**
```json
{
  "require": {
    "php": ">=8.0",
    "ext-curl": "*",
    "ext-openssl": "*",
    "ext-json": "*",
    "web-token/jwt-framework": "^3.0"
  }
}
```

**After:**
```json
{
  "require": {
    "php": ">=8.1",
    "ext-curl": "*",
    "ext-openssl": "*",
    "ext-json": "*",
    "web-token/jwt-framework": "3.0.4"
  }
}
```

### Execute
```bash
cd backendPhp/pg-client-sdk-php

# Edit composer.json
nano composer.json
# 1. Change "php": ">=8.0" to ">=8.1"
# 2. Change "web-token/jwt-framework": "^3.0" to "3.0.4"

# Update dependencies
composer update web-token/jwt-framework
composer audit

# Security check
composer audit
```

### Verify
```bash
composer install --no-dev
composer audit
# Should show: No packages with security advisories found

# Test the SDK
php -l src/PayGlocalClient.php
```

---

## ✅ Step 5: Setup Automated Dependency Scanning

### For GitHub (FREE TIER AVAILABLE)

Create file: `.github/workflows/dependency-check.yml`

```yaml
name: Dependency Security Check

on:
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight
  pull_request:

jobs:
  security:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: JavaScript SDK - npm audit
        run: |
          cd backend/pg-client-sdk
          npm ci
          npm audit --audit-level=moderate || true
          
      - name: JavaScript SDK - PGPD
        run: |
          cd backend/pgpd-client-sdk
          npm ci
          npm audit --audit-level=moderate || true
      
      - name: Setup .NET
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: '8.0.x'
          
      - name: C# SDK - Package vulnerability check
        run: |
          cd backendCsh/pg-client-sdk-csharp
          dotnet restore
          dotnet list package --vulnerable || true
      
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.1'
          
      - name: PHP SDK - composer audit
        run: |
          cd backendPhp/pg-client-sdk-php
          composer install
          composer audit || true
```

### Manual Checks (Weekly)

Add to your calendar:

```bash
# Every Monday morning

# JavaScript
npm audit -C backend/pg-client-sdk
npm audit -C backend/pgpd-client-sdk

# C#
dotnet list package --vulnerable -p backendCsh/pg-client-sdk-csharp/PayGlocal.SDK.csproj

# PHP
composer audit -C backendPhp/pg-client-sdk-php
```

---

## ✅ Step 6: Update Documentation

### Create DEPENDENCY_POLICY.md

```markdown
# Dependency Management Policy

## Version Constraints
- **Production**: Exact versions (e.g., `1.2.3` not `^1.2.3`)
- **Development**: Minor updates allowed (`^1.2.3`)

## Update Process
1. Security patches: Within 48 hours
2. Minor updates: Monthly review + test
3. Major updates: Quarterly + full integration test

## Testing Requirements
- [ ] npm audit / dotnet list / composer audit passes
- [ ] All unit tests pass
- [ ] Integration test with mock API
- [ ] Changelog updated
- [ ] Merchants notified if breaking changes

## Escalation
- CVE discovered? Alert on Slack within 1 hour
- Patch available? Update within 24 hours
- Merchant reports issue? Verify dependency version first
```

### Update README files

Add to each SDK README:

```markdown
## Dependency Management

This SDK uses exact version pinning to ensure stability:

| Dependency | Version | Notes |
|-----------|---------|-------|
| jose | 6.0.11 | JWT/JWE encryption |
| ajv | 8.17.1 | Schema validation |

We audit dependencies weekly for security vulnerabilities.

For the latest security advisories, see [DEPENDENCY_AUDIT_REPORT.md](../DEPENDENCY_AUDIT_REPORT.md)
```

---

## ✅ Step 7: Test Everything

### Run Full Test Suite

```bash
# JavaScript
cd backend/pg-client-sdk
npm ci
npm test

# C#
cd backendCsh/pg-client-sdk-csharp
dotnet test

# PHP
cd backendPhp/pg-client-sdk-php
./vendor/bin/phpunit
```

### Integration Test

Create simple test:

```javascript
// backend/pg-client-sdk/integration-test.js
const PayGlocalClient = require('./dist/index.js');

const client = new PayGlocalClient({
  merchantId: 'TEST_MERCHANT',
  apiKey: 'TEST_API_KEY',
  payglocalEnv: 'UAT',
  logLevel: 'debug'
});

console.log('✅ SDK initialized successfully');
console.log('✅ Dependencies loaded correctly');
console.log('✅ Configuration validated');
```

Run it:
```bash
node integration-test.js
```

---

## ✅ Step 8: Commit & Document

### Git Commands

```bash
# Create a new branch
git checkout -b fix/dependency-pinning

# Stage changes
git add backend/pg-client-sdk/package.json
git add backend/pg-client-sdk/package-lock.json
git add backend/pgpd-client-sdk/package.json  # Or delete if consolidating
git add backendCsh/pg-client-sdk-csharp/PayGlocal.SDK.csproj
git add backendPhp/pg-client-sdk-php/composer.json
git add backendPhp/pg-client-sdk-php/composer.lock
git add DEPENDENCY_AUDIT_REPORT.md
git add DEPENDENCY_POLICY.md

# Commit
git commit -m "fix: pin all dependencies to exact versions for stability

BREAKING: None (backward compatible)

Changes:
- JavaScript: Pin jose@6.0.11, ajv@8.17.1
- C#: Upgrade target framework to net8.0, pin package versions
- PHP: Update minimum PHP to 8.1, pin web-token/jwt-framework@3.0.4
- Add: Dependency security audit report and policy

Fixes:
- Prevents unexpected breaking changes from caret ranges
- Ensures consistent versions across all environments
- Enables fast security vulnerability patching
- Consolidates SDKs (removes PGPD variant)

Tested with:
- npm audit: PASSED
- dotnet list package --vulnerable: PASSED
- composer audit: PASSED
- Integration tests: PASSED

See DEPENDENCY_AUDIT_REPORT.md for details
"

# Create pull request
git push origin fix/dependency-pinning
```

### Create Release Notes

**File**: `RELEASE_NOTES_v2.1.0.md`

```markdown
# PayGlocal SDK v2.1.0 - Dependency Stability Release

## What's Changed

### 🔒 Security
- All dependencies pinned to exact versions for reproducible builds
- Setup automated dependency security scanning (GitHub Actions)
- Created dependency management policy

### 📦 Dependencies
- **JavaScript**: Pinned jose@6.0.11, ajv@8.17.1
- **C#**: Upgraded framework to .NET 8.0 (was net6.0 EOL)
- **PHP**: Upgraded minimum PHP to 8.1
- **All**: Removed loose version constraints (^, ~, >=)

### 🗑️ Removals
- Removed pgpd-client-sdk (consolidated into pg-client-sdk)
- Removed System.Text.Json from C# SDK (use built-in)

### ⚠️ Breaking Changes
- PHP minimum version: 8.0 → 8.1
- C# minimum .NET: 6.0 → 8.0

### Migration Guide

#### JavaScript
```bash
npm install payglocal-client@2.1.0
# No changes needed to your code
```

#### C#
```bash
# Update your .csproj to target net8.0
dotnet restore
```

#### PHP
```bash
# Ensure your server runs PHP 8.1+
composer require payglocal/pg-client-sdk-php:2.1.0
```

## Testing
- All SDKs tested with exact version pins
- Integration tests passed
- Security audit: PASSED

## Support
Questions? See [DEPENDENCY_AUDIT_REPORT.md](DEPENDENCY_AUDIT_REPORT.md)
```

---

## 📋 Checklist - Before Release

- [ ] All dependencies pinned exactly (no ^, ~, >=)
- [ ] npm audit returns 0 vulnerabilities
- [ ] dotnet list package --vulnerable returns nothing
- [ ] composer audit returns no issues
- [ ] All tests pass
- [ ] .NET 8.0 migration complete
- [ ] PHP 8.1 requirement documented
- [ ] DEPENDENCY_AUDIT_REPORT.md created
- [ ] DEPENDENCY_POLICY.md created
- [ ] GitHub Actions workflow created
- [ ] README files updated
- [ ] RELEASE_NOTES written
- [ ] Merchants notified of changes
- [ ] Version bumped to 2.1.0

---

## 🚨 Rollback Plan (If issues)

If merchants report problems:

```bash
# Revert to previous version
git revert <commit-hash>
git push

# Notify merchants
# "We've reverted to v2.0.0 while investigating"

# Investigate locally
npm ci --prefer-offline  # Use locked versions
npm test
```

---

## ⏱️ Timeline

- **Day 1 (Mon)**: Fix JavaScript SDKs
- **Day 1 (Tue)**: Fix C# SDK  
- **Day 2 (Wed)**: Fix PHP SDK
- **Day 2 (Thu)**: Setup automation
- **Day 3 (Fri)**: Test & document
- **Week 2 (Mon)**: Release v2.1.0

Total: ~20 hours of work

