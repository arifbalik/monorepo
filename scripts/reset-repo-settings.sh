#!/bin/sh

gh api \
  --method PATCH \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  'repos/{owner}/{repo}' \
  -f "name=monorepo" \
  -f "description=Personal monorepo playground" \
  -f "homepage=" \
  -F "private=false" \
  -f "visibility=public" \
  -f "security_and_analysis[secret_scanning][status]"=enabled \
  -f "security_and_analysis[secret_scanning_push_protection][status]"=enabled \
  -f "security_and_analysis[secret_scanning_non_provider_patterns][status]"=enabled \
  -F "has_issues=true" \
  -F "has_projects=true" \
  -F "has_wiki=true" \
  -F "is_template=true" \
  -f "default_branch=main" \
  -F "allow_squash_merge=true" \
  -F "allow_merge_commit=false" \
  -F "allow_rebase_merge=false" \
  -F "allow_auto_merge=false" \
  -F "delete_branch_on_merge=true" \
  -F "allow_update_branch=true" \
  -f "squash_merge_commit_title=COMMIT_OR_PR_TITLE" \
  -f "squash_merge_commit_message=COMMIT_MESSAGES" \
  -f "merge_commit_title=PR_TITLE" \
  -f "merge_commit_message=PR_BODY" \
  -F "archived=false" \
  -F "web_commit_signoff_required=true"

ruleset_name="default ruleset"
rulesets=$(gh api 'repos/{owner}/{repo}/rulesets')
ruleset_id=$(echo "$rulesets" | jq -r ".[] | select(.name == \"$ruleset_name\") | .id")
# shellcheck disable=SC2089
rules='{
  "name": "'$ruleset_name'",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "exclude": [],
      "include": [
        "~DEFAULT_BRANCH"
      ]
    }
  },
  "rules": [
    {
      "type": "deletion"
    },
    {
      "type": "non_fast_forward"
    },
    {
      "type": "required_signatures"
    },
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
          {
            "context": "check-pr-size"
          },
          {
            "context": "MegaLinter"
          },
          {
            "context": "commitlint"
          }
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

if [ -n "$ruleset_id" ]; then
  gh api \
  --method DELETE \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  'repos/{owner}/{repo}/rulesets/'"$ruleset_id"
fi

echo "$rules" | gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  'repos/{owner}/{repo}/rulesets' --input -
