# How I Set Up My Self Monorepo

I've been using monorepos for commercial projects for a while now and I've come to appreciate the benefits they bring, so I've been thinking about doing the same for my personal projects.  In this post, I'll share how I set up my self monorepo, so that hopefully you can do it too.

## What is a monorepo?

A monorepo is simply a collection of would-be repositories in a single repository. Usually all source files, issues and other materials and processes of an organization or a subset of it are stored in a single repository. This method is already used by big companies like Google and Microsoft and Github is continuing to extend it's support for monorepos -since they are also using it in Microsoft.

## Why a monorepo?

## Main focus of this personal monorepo is on Embedded Systems

I'm an embedded systems engineer, so my monorepo would be built around embedded systems. My tooling, CI/CD pipelines and other thing would be taiolored to this domain. For instance having Zephyr devcontainers, or common KiCad component libraries etc.

## Setting up the monorepo

There are monorepo tools out there that can be much better tailored to your needs, but here I tried to do things a little more manually to allow more custimization to see how it will evolve with __my__ needs.

Techs and tools I'm going to use:

- A Linux machine (I used Ubuntu 20.04)
- Git (duh)
- GitHub
- VSCode
- npm
  - commitlint
  - mega-linter-runner
  - husky
  - devcontainers/cli
- Docker
- Github Actions
  - commitlint
  - mega-linter
  - docker build

I heavily use the GitHub features and leverage them to really automate the process. If you're planning to use a different VCS, you can still use most of the things here or tweak some files and search for similar settings in your VCS.

### Initialize the repository

First thing to do is to create a new repository on GitHub. I named mine `monorepo`. Gave it a GPL-3.0 license and a README.md file.

After creating the repository, we need to enforce some rules to keep our repo safe, this is mostly for public repos but if you have multiple people working on this or just for the sake of best practices you can apply them.

Go to `Settings` in your monorepo in GitHub and change the following settings:

- Set the `Default commit message` for PRs to PR title and description so your merge commits will be consistent (assuming you are using conventionalcommits in titles, and you can automate this as well!)
- Enable `Always suggest updating pull request branches`
- Enable `Automatically delete head branches`
- (Optional) Only allow squash merging

Then go to `Rulesets` and create a new ruleset. I named mine `general`. In this ruleset, I set the following rules:

- I allowed myself to be able to bypass the ruleset (to avoid inconveniences for solo projects)
- Apply the ruleset only to the `main` branch (free development on and between other branches)
- Enable `Restrict deletions`
- Enable `Require signed commits` (always)
- Enable `Require a pull request before merging`
- Enable `Require status checks to pass`
  - Add `commitlint` and `mega-linter` checks
- Enable `Block force pushes`

These settings will make sure your braches which is merged to `main` will be deleted and not force pushed accidentely or stay on GitHub forever. You will have a nice convinient button right above the merge button to update your PR branch with the latest changes in `main`, so if one of the actions got updated before this merge which breaks the CI, you can catch it.

The rulesets basically treat main as production version of your codebase, and you can freely develop on other branches, but when you are ready to merge to main, you have to make sure your commits are in the conventional commit format and your codebase is clean and linted properly. Otherwise it's a no go.

Clone the repository to your local machine:

```bash
git clone <your-repo-url>
```

Make sure you have either SSH or GPG commit signing enabled. Read more about it [here](https://docs.github.com/en/github/authenticating-to-github/managing-commit-signature-verification).

### Commit linter

First thing to set up is a commit linter. I use [commitlint](https://commitlint.js.org/) for this. It's a simple tool that checks if your commit messages meet the conventional commit format. This is important because it helps with automatic versioning and changelog generation. Also keeps your git history clean and easy to read and make you able to apply automated tools to exract insights later on.

To set up `commitlint`, first install it with npm:

```bash
npm install --save-dev @commitlint/config-conventional @commitlint/cli
```

Then create a configuration file in the root of your repository:

```bash
echo "export default { extends: ['@commitlint/config-conventional'] };" > commitlint.config.js
```

This configuration uses the conventional commit format. You can find more information about it [here](https://www.conventionalcommits.org/en/v1.0.0/).

#### Add hooks

To make sure that all commits are linted, you can add a git hook. I used `husky` for this as recommended in the [docs](https://commitlint.js.org/guides/local-setup.html).

```bash
npm install --save-dev husky
```

Then add a script to your `package.json`:

```bash
npm pkg set scripts.commitlint="commitlint --edit"
```

Finally add the hook:

```bash
echo "npm run commitlint \${1}" > .husky/commit-msg
```

Now every time you commit, the commit message will be checked against the conventional commit format.

> [!NOTE]
> As of this writing the husky version used is `husky@v9` which creates `pre-commit` hook, but commintlint does not support `pre-commit` yet, so if you have a `pre-commit` hook inside newly created `.husky` folder, and you are having issues with it, you can remove it for now.

For more detailed information on package `commitlint`, check out the [official documentation](https://commitlint.js.org/guides/getting-started.html).

### Code Owners

Another thing I set up is code owners. A monorepo by its nature contains multiple projects, and it is usually the case that more than one people may work on them. So it is crucial to define who is responsible for what.

This is where code owners come in. GitHub codeowners feature allows you to define who is responsible for what part of the codebase and it can be used to make sure only people who are responsible for a part of the code can merge code into it.

To set up code owners, create a file named `CODEOWNERS` in the root of your repository. And define the initial owners file like this:

```bash
* @<your-username>
```

This will initially make you the sole responsible person for every single file in the repository. You can later add people down the line so that the wildcard will only be used as a fallback.

```bash
* @<your-username>

/path/to/some/file @<another-username>

*.js @<another-username> @<yet-another-username>
```

For more detailed information on code owners, check out the [official documentation](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/about-code-owners).

### Development Containers

For a monorepo, you need a mono development environment. Well, actually more than one development environment, but at least you need them to be consistent everywhere, anytime.

This is exactly what `Dev Containers` solve. A dev container is just a docker image that has everything for a good, robust and smooth developer experience for a given task, what makes it different from a normal docker image is just some vscode features that makes it easy to create, edit and use them. VSCode kinda becomes the "GUI" for our docker images.

In my case I have a Zephyr devcontainer for Embedded development.

To create any devcontainer, you need a `.devcontainer` folder in the root of your repository. Inside, you can have a single `devcontainer.json` file for a single devcontainer, or use multiple folders with multiple `devcontainer.json` files in each, as I will do.

```bash
mkdir -p .devcontainer/zephyr && code .devcontainer/zephyr/devcontainer.json
```

Then you can define your devcontainer like this:

```json
{
    "name": "Zephyr",
    "build": {
        "dockerfile": "Dockerfile",
        "options": [
            "-t",
            "arifbalik/zephyr-devcontainer:latest"
        ]
    },
    "runArgs": [
        "--name",
        "zephyr-devcontainer"
    ],
    "workspaceMount": "source=monorepo,target=/home/zephyr/workspace,type=volume",
    "workspaceFolder": "/home/zephyr/workspace",
    "customizations": {
    "vscode": {
      "extensions": ["streetsidesoftware.code-spell-checker"]
    }
  },
  "forwardPorts": [3000]
}
```

Which will define the vscode environment, and the image will be inside the same folder's `Dockerfile`.

```Dockerfile
FROM image

...
```

Now you can install package `devcontainers/cli`:

```bash
npm install --save-dev @devcontainers/cli
```

You can then add a scripts to your `package.json` to build your devcontainer and run commands inside it:

```bash
npm pkg set scripts.zephyr-dev="devcontainer up --workspace-folder . --config .devcontainer/zephyr/devcontainer.json"
npm pkg set scripts.zephyr-dev-shell="devcontainer exec --workspace-folder . --config .devcontainer/zephyr/devcontainer.json"
```

Now you can run `npm run zephyr-dev` to start your devcontainer and `npm run zephyr-dev-shell` to run a shell inside it.

```bash
$ npm run zephyr-dev

> zephyr-dev
> devcontainer up --workspace-folder . --config .devcontainer/zephyr/devcontainer.json

[3 ms] @devcontainers/cli 0.67.0. Node.js v20.7.0. linux x64
{"outcome":"success","containerId":"9d959d195def4b25be708df2a3f9b646c3e09b498c1075100bd764b95d6d5f9d","remoteUser":"zephyr","remoteWorkspaceFolder":"/home/zephyr/workspace"}
```

Or better yet you can attach the container and use it as a normal vscode environment. After running `npm run zephyr-dev`, you can attach the container by clicking the green button at the bottom left of the vscode window or using `ctrl+shift+p` and typing `Remote-Containers: Attach to Running Container`.

For more detailed information on package `devcontainers/cli`, check out the [official documentation](https://www.npmjs.com/package/@devcontainers/cli).

Also the VSCode documentation on devcontainers is very helpful, you can check it out [here](https://code.visualstudio.com/docs/remote/containers).

### CI

For CI, I use GitHub Actions. All my workflows are in the `.github/workflows` folder.

Initially I have following workflows:

- `commitlint.yml`
- `mega-linter.yml`
- `docker-build.yml`
- `pr-checks.yml`

#### Commitlint

`commitlint.yml` will run on pull requests (and on individual pushes) and check if the commit messages are in the conventional commit format, so I don't have to rely on the husky hooks and require squash commits or reject the PR if the commit messages are not in the correct format.

```yaml
name: Commitlint CI

on: [push, pull_request]

jobs:
  commitlint:
    runs-on: ubuntu-22.04
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: Install required dependencies
        run: |
          apt update
          apt install -y sudo
          sudo apt install -y git curl
          curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
          sudo DEBIAN_FRONTEND=noninteractive apt install -y nodejs
      - name: Print versions
        run: |
          git --version
          node --version
          npm --version
          npx commitlint --version
      - name: Install commitlint
        run: |
          npm install conventional-changelog-conventionalcommits
          npm install commitlint@latest

      - name: Validate current commit (last commit) with commitlint
        if: github.event_name == 'push'
        run: npx commitlint --last --verbose

      - name: Validate PR commits with commitlint
        if: github.event_name == 'pull_request'
        run: npx commitlint --from ${{ github.event.pull_request.head.sha }}~${{ github.event.pull_request.commits }} --to ${{ github.event.pull_request.head.sha }} --verbose
```

This is the workflow recommended in the [commitlint docs](https://commitlint.js.org/guides/ci-setup.html).

#### MegaLinter

MegaLinter is a great tool to run your entire codebase with different linters.

`mega-linter.yml` will again run on pull requests and comment a report on the PR with the results on the PR discussion. This is a great way to keep your codebase clean and consistent. You can even make it a required check for merging PRs, check out the [official documentation](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/about-status-checks).

```yaml
# MegaLinter GitHub Action configuration file
# More info at https://megalinter.io
---
name: MegaLinter

# Trigger mega-linter at every push. Action will also be visible from Pull
# Requests to main
on:
  # Comment this line to trigger action only on pull-requests
  # (not recommended if you don't pay for GH Actions)
  push:

  pull_request:
    branches:
      - main
      - master

# Comment env block if you do not want to apply fixes
env:
  # Apply linter fixes configuration
  #
  # When active, APPLY_FIXES must also be defined as environment variable
  # (in github/workflows/mega-linter.yml or other CI tool)
  APPLY_FIXES: all

  # Decide which event triggers application of fixes in a commit or a PR
  # (pull_request, push, all)
  APPLY_FIXES_EVENT: pull_request

  # If APPLY_FIXES is used, defines if the fixes are directly committed (commit)
  # or posted in a PR (pull_request)
  APPLY_FIXES_MODE: commit

concurrency:
  group: ${{ github.ref }}-${{ github.workflow }}
  cancel-in-progress: true

jobs:
  megalinter:
    name: MegaLinter
    runs-on: ubuntu-latest

    # Give the default GITHUB_TOKEN write permission to commit and push, comment
    # issues & post new PR; remove the ones you do not need
    permissions:
      contents: write
      issues: write
      pull-requests: write

    steps:

      # Git Checkout
      - name: Checkout Code
        uses: actions/checkout@v4
        with:
          token: ${{ secrets.PAT || secrets.GITHUB_TOKEN }}

          # If you use VALIDATE_ALL_CODEBASE = true, you can remove this line to
          # improve performance
          fetch-depth: 0

      # MegaLinter
      - name: MegaLinter

        # You can override MegaLinter flavor used to have faster performances
        # More info at https://megalinter.io/flavors/
        uses: oxsecurity/megalinter@v7

        id: ml

        # All available variables are described in documentation
        # https://megalinter.io/configuration/
        env:

          # Validates all source when push on main, else just the git diff with
          # main. Override with true if you always want to lint all sources
          #
          # To validate the entire codebase, set to:
          # VALIDATE_ALL_CODEBASE: true
          #
          # To validate only diff with main, set to:
          # VALIDATE_ALL_CODEBASE: >-
          #   ${{
          #     github.event_name == 'push' &&
          #     contains(fromJSON('["refs/heads/main", "refs/heads/master"]'), github.ref)
          #   }}
          VALIDATE_ALL_CODEBASE: >-
            ${{
              github.event_name == 'push' &&
              contains(fromJSON('["refs/heads/main", "refs/heads/master"]'), github.ref)
            }}

          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

          # ADD YOUR CUSTOM ENV VARIABLES HERE OR DEFINE THEM IN A FILE
          # .mega-linter.yml AT THE ROOT OF YOUR REPOSITORY

          # Uncomment to disable copy-paste and spell checks
          # DISABLE: COPYPASTE,SPELL

      # Upload MegaLinter artifacts
      - name: Archive production artifacts
        uses: actions/upload-artifact@v4
        if: success() || failure()
        with:
          name: MegaLinter reports
          path: |
            megalinter-reports
            mega-linter.log

      # Set APPLY_FIXES_IF var for use in future steps
      - name: Set APPLY_FIXES_IF var
        run: |
          printf 'APPLY_FIXES_IF=%s\n' "${{
            steps.ml.outputs.has_updated_sources == 1 &&
            (
              env.APPLY_FIXES_EVENT == 'all' ||
              env.APPLY_FIXES_EVENT == github.event_name
            ) &&
            (
              github.event_name == 'push' ||
              github.event.pull_request.head.repo.full_name == github.repository
            )
          }}" >> "${GITHUB_ENV}"

      # Set APPLY_FIXES_IF_* vars for use in future steps
      - name: Set APPLY_FIXES_IF_* vars
        run: |
          printf 'APPLY_FIXES_IF_PR=%s\n' "${{
            env.APPLY_FIXES_IF == 'true' &&
            env.APPLY_FIXES_MODE == 'pull_request'
          }}" >> "${GITHUB_ENV}"
          printf 'APPLY_FIXES_IF_COMMIT=%s\n' "${{
            env.APPLY_FIXES_IF == 'true' &&
            env.APPLY_FIXES_MODE == 'commit' &&
            (!contains(fromJSON('["refs/heads/main", "refs/heads/master"]'), github.ref))
          }}" >> "${GITHUB_ENV}"

      # Create pull request if applicable
      # (for now works only on PR from same repository, not from forks)
      - name: Create Pull Request with applied fixes
        uses: peter-evans/create-pull-request@v6
        id: cpr
        if: env.APPLY_FIXES_IF_PR == 'true'
        with:
          token: ${{ secrets.PAT || secrets.GITHUB_TOKEN }}
          commit-message: "[MegaLinter] Apply linters automatic fixes"
          title: "[MegaLinter] Apply linters automatic fixes"
          labels: bot

      - name: Create PR output
        if: env.APPLY_FIXES_IF_PR == 'true'
        run: |
          echo "PR Number - ${{ steps.cpr.outputs.pull-request-number }}"
          echo "PR URL - ${{ steps.cpr.outputs.pull-request-url }}"

      # Push new commit if applicable
      # (for now works only on PR from same repository, not from forks)
      - name: Prepare commit
        if: env.APPLY_FIXES_IF_COMMIT == 'true'
        run: sudo chown -Rc $UID .git/

      - name: Commit and push applied linter fixes
        uses: stefanzweifel/git-auto-commit-action@v4
        if: env.APPLY_FIXES_IF_COMMIT == 'true'
        with:
          branch: >-
            ${{
              github.event.pull_request.head.ref ||
              github.head_ref ||
              github.ref
            }}
          commit_message: "[MegaLinter] Apply linters fixes"
          commit_user_name: megalinter-bot
          commit_user_email: nicolas.vuillamy@ox.security
```

Of course every language linting configuration can be customized, check out the [official documentation](https://megalinter.io/configuration/).

In my case I have a `megalinter.yml` file in the root of my repository, this is some environment files that configures which linters I want and which settings I want to override etc.

```yaml
# Configuration file for MegaLinter

# all, none, or list of linter keys (assumming this runs locally and not on CI)
APPLY_FIXES: all

CLEAR_REPORT_FOLDER: true

DEFAULT_BRANCH: main

VALIDATE_ALL_CODEBASE: false

ENABLE_LINTERS:
  - MARKDOWN_MARKDOWNLINT
  - BASH_SHELLCHECK
  - REPOSITORY_GIT_DIFF
  - PYTHON_BLACK
  - JSON_ESLINT_PLUGIN_JSONC
  - C_CLANG_FORMAT
  - MAKEFILE_CHECKMAKE
  - JAVASCRIPT_PRETTIER
  - CSHARP_ROSLYNATOR
  - GO_GOLANGCI_LINT
  - MAKEFILE_CHECKMAKE
  - POWERSHELL_POWERSHELL
  - SQL_SQLFLUFF
  - PROTOBUF_PROTOLINT
  - YAML_PRETTIER
  - DOCKERFILE_HADOLINT
  - SPELL_PROSELINT

SHOW_ELAPSED_TIME: true

FILEIO_REPORTER: false

LINTER_RULES_PATH: .github/linters

C_CLANG_FORMAT_CONFIG_FILE: .clang-format

LOG_LEVEL: INFO

PARALLEL_PROCESS_NUMBER: 20
```

And I put a `.clang-format` file in `.github/linters` folder to configure the `C_CLANG_FORMAT` linter.

```yaml
---
DisableFormat: false
AccessModifierOffset: -4
AlignAfterOpenBracket: BlockIndent
AlignConsecutiveMacros:
  Enabled: true
  AcrossEmptyLines: false
  AcrossComments: false
AlignConsecutiveDeclarations: AcrossEmptyLines
AlignEscapedNewlines: Right
AlignOperands: AlignAfterOperator
AlignTrailingComments: Always
AllowAllArgumentsOnNextLine: false
AllowAllParametersOfDeclarationOnNextLine: false
AllowShortBlocksOnASingleLine: Always
AllowShortCaseLabelsOnASingleLine: true
AllowShortFunctionsOnASingleLine: true
AllowShortIfStatementsOnASingleLine: AllIfsAndElse
AllowShortLoopsOnASingleLine: true
AlwaysBreakAfterDefinitionReturnType: None
AlwaysBreakAfterReturnType: None
AlwaysBreakBeforeMultilineStrings: true
BinPackArguments: true
BinPackParameters: true
BitFieldColonSpacing: Both
BraceWrapping:
  AfterClass: false
  AfterControlStatement: true
  AfterEnum: false
  AfterFunction: true
  AfterNamespace: true
  AfterStruct: false
  AfterUnion: false
  AfterExternBlock: false
  BeforeElse: true
  IndentBraces: false
  SplitEmptyFunction: true
  SplitEmptyRecord: true
  SplitEmptyNamespace: true
BracedInitializerIndentWidth: 2
BreakArrays: false
BreakBeforeBinaryOperators: None
BreakBeforeBraces: Custom
BreakBeforeTernaryOperators: true
BreakConstructorInitializers: BeforeComma
BreakStringLiterals: true
ColumnLimit: 0
CommentPragmas: "^ IWYU pragma:"
CompactNamespaces: false
ConstructorInitializerIndentWidth: 8
ContinuationIndentWidth: 8
DerivePointerAlignment: false
EmptyLineAfterAccessModifier: Always
ExperimentalAutoDetectBinPacking: true
FixNamespaceComments: true
IncludeBlocks: Regroup
IncludeCategories:
  - Regex: ".*"
    Priority: 1
IncludeIsMainRegex: "(Test)?$"
IndentCaseLabels: true
IndentGotoLabels: true
IndentPPDirectives: AfterHash
IndentWidth: 8
IndentWrappedFunctionNames: false
KeepEmptyLinesAtTheStartOfBlocks: false
MaxEmptyLinesToKeep: 1
NamespaceIndentation: None
PointerAlignment: Right
ReflowComments: true
SortIncludes: false
SpaceAfterCStyleCast: false
SpaceAfterTemplateKeyword: true
SpaceBeforeAssignmentOperators: true
SpaceBeforeCtorInitializerColon: true
SpaceBeforeParens: ControlStatementsExceptForEachMacros
SpaceBeforeRangeBasedForLoopColon: true
SpaceInEmptyParentheses: false
SpacesBeforeTrailingComments: 1
SpacesInAngles: false
SpacesInContainerLiterals: false
SpacesInCStyleCastParentheses: false
SpacesInParentheses: false
SpacesInSquareBrackets: false
TabWidth: 8
UseTab: Always
```

Which is how I like my C code to be formatted.

And while we are at it, we can add a script to our `package.json` to run the megalinter locally and fix any linting issue before pushing the code.

```bash
npm pkg set scripts.lint="npx mega-linter-runner --fix"
```

You can even add a hook to run this script before every commit or every push, but i will leave that to you, dear reader.

#### Docker Build

#### PR Checks

PR checks is general stuff we need to check in a PR, most imporantly it's size which in my case is limited to 500 lines of code. I think above which you start to lose the context of the PR and it becomes hard to review in a meaningful time.

Also things like assignees, labels, milestones etc. can be checked and enforced in this workflow.

```yaml
name: PR Watcher

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  check-pr-size:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
    steps:
      - uses: actions/github-script@v7
        with:
          script: |
            const MAX_PR_SIZE = parseInt(process.env.MAX_PR_SIZE);
            const pr = context.payload.pull_request;
            if (pr.additions > MAX_PR_SIZE) {
              github.rest.issues.createComment({
              issue_number: pr.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `:x: PR size is too large. Please keep PR size under ${MAX_PR_SIZE} additions.`
              });
              core.setFailed(`PR size is too large. Please keep PR size under ${MAX_PR_SIZE} additions.`);
            } else { core.notice(`PR size is within limits.`); }
        env:
          MAX_PR_SIZE: 200
```

I think up to this point mostly all tools is set up for a personal monorepo. You ensured nice and quality commits, you have a consistent development environment so it always works on everybody's machine, and you have CI workflows that checks your codebase for quality and consistency.

The rest of it is up to your specific needs. You can add more workflows, more linters, more devcontainers etc. But I think this is a good starting point. If you have any questions or suggestions, feel free to open an issue or a better yet a PR.

### Self-hosted runners (Optional, but highly recommended)
