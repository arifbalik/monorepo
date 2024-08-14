#!/bin/sh

# shellcheck disable=SC2086

if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI is not authenticated. Please authenticate using 'gh auth login' and try again."
  exit 1
fi

# Common headers and endpoint
headers="-H Accept:application/vnd.github+json -H X-GitHub-Api-Version:2022-11-28"
owner=$(gh api user | jq -r .login)
repo=$(git config --get remote.origin.url | sed -E 's/.*\/([^/]+)\.git/\1/')
repo_endpoint="repos/$owner/$repo"

# Repository settings
repo_settings='{
  "name": "monorepo",
  "description": "Generic monorepo template",
  "homepage": "arifbalik.github.io/monorepo/",
  "private": false,
  "visibility": "public",
  "security_and_analysis": {
    "secret_scanning": {
      "status": "enabled"
    },
    "secret_scanning_push_protection": {
      "status": "enabled"
    },
    "dependabot_security_updates": {
      "status": "enabled"
    },
    "secret_scanning_non_provider_patterns": {
      "status": "enabled"
    },
    "secret_scanning_validity_checks": {
      "status": "enabled"
    }
  },
  "has_issues": true,
  "has_projects": true,
  "has_wiki": true,
  "is_template": true,
  "default_branch": "main",
  "allow_squash_merge": true,
  "allow_merge_commit": false,
  "allow_rebase_merge": false,
  "allow_auto_merge": false,
  "delete_branch_on_merge": true,
  "allow_update_branch": true,
  "squash_merge_commit_title": "COMMIT_OR_PR_TITLE",
  "squash_merge_commit_message": "COMMIT_MESSAGES",
  "archived": false,
  "web_commit_signoff_required": true
}'

# Ruleset settings
ruleset_name="default ruleset"
ruleset_id=$(gh api "$repo_endpoint/rulesets" | jq -r ".[] | select(.name == \"$ruleset_name\") | .id")
rules='{
  "name": "'$ruleset_name'",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "exclude": [],
      "include": ["~DEFAULT_BRANCH"]
    }
  },
  "rules": [
    {"type": "deletion"},
    {"type": "non_fast_forward"},
    {"type": "required_signatures"},
    {
      "type": "pull_request",
      "parameters": {
        "required_approving_review_count": 1,
        "dismiss_stale_reviews_on_push": true,
        "require_code_owner_review": false,
        "require_last_push_approval": true,
        "required_review_thread_resolution": true
      }
    },
    {
      "type": "required_status_checks",
      "parameters": {
        "strict_required_status_checks_policy": false,
        "do_not_enforce_on_create": false,
        "required_status_checks": [
          {"context": "check-pr-size"},
          {"context": "MegaLinter"},
          {"context": "commitlint"}
        ]
      }
    }
  ],
  "bypass_actors": [
    {
      "actor_id": 5,
      "actor_type": "RepositoryRole",
      "bypass_mode": "always"
    }
  ]
}'

# Apply repo settings
echo "$repo_settings" | gh api --method PATCH $headers "$repo_endpoint" --input -

# Check and configure GitHub Pages
if ! gh api $headers "$repo_endpoint/pages"; then
  gh api --method DELETE $headers "$repo_endpoint/pages"
fi

gh api --method POST $headers "$repo_endpoint/pages" -f "source[branch]=main" -f "source[path]=/"

# Apply ruleset
if [ -n "$ruleset_id" ]; then
  gh api --method DELETE $headers "$repo_endpoint/rulesets/$ruleset_id"
fi

echo "$rules" | gh api --method POST $headers "$repo_endpoint/rulesets" --input -

# Check if the remote 'template' exists, if not add it
if ! git remote | grep -q '^template$'; then
  git remote add template https://github.com/arifbalik/monorepo.git
fi
gh repo set-default "$owner/$repo"

git maintenance start