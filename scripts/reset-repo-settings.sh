gh api --method PATCH -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" repos/{owner}/{repo} -f data='{
    "name": "monorepo",
    "description": "A test on personal monorepos",
    "homepage": "",
    "private": false,
    "visibility": "public",
    "security_and_analysis": {
      "advanced_security": { "status": "enabled" },
      "secret_scanning": { "status": "enabled" },
      "secret_scanning_push_protection": { "status": "enabled" },
      "secret_scanning_non_provider_patterns": { "status": "enabled" }
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
    "merge_commit_title": "PR_TITLE",
    "merge_commit_message": "PR_BODY",
    "archived": false,
    "web_commit_signoff_required": true
  }'

ruleset_name="default ruleset"
rulesets=$(gh api repos/{owner}/{repo}/rulesets)
ruleset_id=$(echo $rulesets | jq -r ".[] | select(.name == \"$ruleset_name\") | .id")
rules_path="scripts/repo-rules.json"

echo "Ruleset ID: $ruleset_id"

if [ -z "$ruleset_id" ]; then
  echo "Ruleset not found with the name $ruleset_name, creating a new ruleset"
  # add field name to rules.json
  jq ". + {\"name\": \"$ruleset_name\"}" $rules_path > tmp.json && mv tmp.json $rules_path
  gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  repos/{owner}/{repo}/rulesets \
  --input $rules_path
else 
 echo "Ruleset found with the name $ruleset_name, updating the ruleset"
  gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  repos/{owner}/{repo}/rulesets/$ruleset_id \
  --input $rules_path
fi
