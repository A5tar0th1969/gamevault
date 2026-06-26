#!/usr/bin/env bash
# GameVault — GitHub Repository Setup
# Run: ./setup-github.sh
#
# Prerequisites:
#   - git configured (git config --global user.name "Your Name")
#   - GitHub personal access token with repo scope
#   - OR gh CLI installed and authenticated

set -euo pipefail

REPO_NAME="${1:-gamevault}"
REPO_DESC="Cross-platform gaming launcher with Steam, Xbox Game Pass & Epic Games Store — Aniki ReMake UI, fullscreen game mode, Linux support"
GITHUB_USER=""

echo "🎮 GameVault — GitHub Repository Setup"
echo ""

# Detect GitHub user
detect_user() {
  # Try gh CLI first
  if command -v gh &>/dev/null; then
    GITHUB_USER=$(gh api user --jq '.login' 2>/dev/null || true)
    if [ -n "$GITHUB_USER" ]; then
      echo "✓ Detected GitHub user via gh CLI: $GITHUB_USER"
      return 0
    fi
  fi

  # Try git config
  GITHUB_USER=$(git config --global github.user 2>/dev/null || true)
  if [ -n "$GITHUB_USER" ]; then
    echo "✓ Detected GitHub user via git config: $GITHUB_USER"
    return 0
  fi

  # Prompt
  read -r -p "Enter your GitHub username: " GITHUB_USER
  if [ -z "$GITHUB_USER" ]; then
    echo "❌ GitHub username required"
    exit 1
  fi
}

# Create repo via GitHub API
create_repo_api() {
  local token=""
  local token_source=""

  # Check for token
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    token="$GITHUB_TOKEN"
    token_source="GITHUB_TOKEN env var"
  elif [ -n "${GH_TOKEN:-}" ]; then
    token="$GH_TOKEN"
    token_source="GH_TOKEN env var"
  elif [ -f ~/.github-token ]; then
    token=$(cat ~/.github-token)
    token_source="~/.github-token file"
  else
    echo ""
    echo "🔑 No GitHub token found."
    echo "   Create a token at: https://github.com/settings/tokens (scope: repo)"
    read -r -s -p "   Enter your GitHub personal access token: " token
    echo ""
    if [ -z "$token" ]; then
      echo "❌ Token required. Set GITHUB_TOKEN env var or create ~/.github-token"
      return 1
    fi
  fi

  echo "   Using token from: $token_source"
  echo "   Creating repository '$REPO_NAME'..."

  local response
  response=$(curl -s -w "\n%{http_code}" -X POST "https://api.github.com/user/repos" \
    -H "Authorization: token $token" \
    -H "Content-Type: application/json" \
    -d "{
      \"name\": \"$REPO_NAME\",
      \"description\": \"$REPO_DESC\",
      \"private\": false,
      \"has_issues\": true,
      \"has_projects\": false,
      \"has_wiki\": false
    }")

  local http_code
  http_code=$(echo "$response" | tail -1)
  local body
  body=$(echo "$response" | sed '$d')

  if [ "$http_code" = "201" ]; then
    echo "✓ Repository created: https://github.com/$GITHUB_USER/$REPO_NAME"
    return 0
  elif [ "$http_code" = "422" ]; then
    echo "ℹ️  Repository may already exist. Attempting push..."
    return 0
  else
    echo "❌ Failed to create repository (HTTP $http_code)"
    echo "$body"
    return 1
  fi
}

# Create repo via gh CLI
create_repo_gh() {
  echo "   Creating repository '$REPO_NAME'..."
  gh repo create "$REPO_NAME" --public --description "$REPO_DESC" --source=. --remote=origin --push
}

# Main
main() {
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  cd "$SCRIPT_DIR"

  # Initialize git if needed
  if [ ! -d .git ]; then
    echo "📦 Initializing git repository..."
    git init
    git add -A
    git commit -m "Initial commit: GameVault cross-platform gaming launcher"
    echo "✓ Git repository initialized"
  fi

  # Check if remote already exists
  if git remote get-url origin &>/dev/null; then
    echo "ℹ️  Remote 'origin' already configured:"
    git remote -v
    echo ""
    echo "To push: git push -u origin main"
    exit 0
  fi

  detect_user

  # Try gh CLI first, fall back to API
  if command -v gh &>/dev/null && gh auth status &>/dev/null 2>&1; then
    create_repo_gh
  else
    create_repo_api || {
      echo ""
      echo "⚠️  Could not create repository automatically."
      echo ""
      echo "Manual setup:"
      echo "  1. Create a repo at https://github.com/new (name: $REPO_NAME)"
      echo "  2. Then run:"
      echo "     git remote add origin https://github.com/$GITHUB_USER/$REPO_NAME.git"
      echo "     git push -u origin main"
      exit 1
    }
  fi

  # Push
  echo "   Pushing to GitHub..."
  git push -u origin main 2>/dev/null || {
    git branch -m main main
    git push -u origin main 2>/dev/null || {
      echo "⚠️  Push failed. Try:"
      echo "   git remote add origin https://github.com/$GITHUB_USER/$REPO_NAME.git"
      echo "   git push -u origin main"
    }
  }

  echo ""
  echo "✅ Done! Repository: https://github.com/$GITHUB_USER/$REPO_NAME"
}

main "$@"
