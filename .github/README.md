# GitHub Actions

This directory contains GitHub Actions workflows for automated code validation and branch protection.

## Workflows

### Pull Request Validation (`pull_request.yml`)

Automatically runs on pull requests and pushes to main/master branches to ensure code quality:

**Triggers:**
- Pull requests to main/master
- Direct pushes to main/master

**Jobs:**
1. **Validate Package** - Main package validation
   - Flutter analyze
   - Flutter test
   - Dart format check

### Branch Protection Setup (`branch_protection.yml`)

Manually triggered workflow to set up branch protection rules for the main branch.

**Protection Rules:**
- Requires status checks to pass before merging
- Requires at least 1 approving review
- Dismisses stale reviews
- Prevents force pushes and deletions
- Enforces strict status checks
- **Only repository owner can merge pull requests**

## Usage

### For Contributors

1. Create a feature branch from main
2. Make your changes
3. Create a pull request
4. The workflows will automatically run
5. All checks must pass before merging
6. **Only the repository owner can merge the PR**

### For Repository Owners

1. Go to Actions tab
2. Run the "Branch Protection Setup" workflow manually
3. This will configure protection rules for the main branch
4. You will be the only one who can merge pull requests

## Requirements

- Flutter 3.32.7 or higher
- All tests must pass
- No analyzer warnings
- Code must be properly formatted
- Only the repository owner can merge pull requests 