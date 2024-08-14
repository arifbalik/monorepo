# Monorepo

I've been using monorepos for commercial projects for a while now and I've come to appreciate the benefits they bring, so I've been thinking about doing the same for my personal projects. This is the template of the monorepo I'll start with and build my personal projects on. So I'll keep everything here as generic as possible and try to keep it up to date with the latest features and best practices.

## What is a monorepo?

A monorepo is simply a collection of would-be repositories in a single repository. Usually all source files, issues and other materials and processes of an organization or a subset of it are stored in a single repository. This brings a lot benefits like easier CI/CD, code reuse etc. This method is already used by big companies like Google and Microsoft and Github is continuing to extend it's support for monorepos -since they are also using it in Microsoft.

## Features

- Devcontainers for reproducible development environments
- Commitlint for consistent commit messages both locally and on CI
- MegaLinter for consistent code quality and linting both locally and on CI
- Self-hosted runners for free CI/CD runs
- Code owners for code responsibility
- Required workflow runs including `pr-watcher` workflow
- Advanced security features enabled like verified commits, branch protection rules etc.
- npm scripts for easy access to features and maintaining monorepo

## Getting Started

### Requirements

- [GH CLI](https://cli.github.com/)
- [npm](https://nodejs.org/en)
- [Docker](https://www.docker.com/)
- [VSCode](https://code.visualstudio.com/)

To use it as your own monorepo, you can click the `Use this template` button at the top of the page or with `gh-cli` you can run the following command:

```bash
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/arifbalik/monorepo/generate \
   -f "owner=your-username" -f "name=my-monorepo" -f "description=A test with monorepos"
```

### Setup

After you've created your own monorepo, you can clone it to your local machine;

```bash
git clone <your-repo-url>
cd <your-repo-name>
```

Then install the dependencies;

```bash
npm install
```

![demo](https://github.com/user-attachments/assets/ee86425e-0faa-4b37-a98d-dc3ad607bb6f)

### Settings

Repo settings are not transferred to your repo when you use the template or fork it, therefore you can edit the `scripts/reset-repo-settings.sh` script to your needs and run it to reset the repo settings.

```bash
npm run reset-repo
```

![demo](https://github.com/user-attachments/assets/7fc0a034-4ddd-4fb0-b161-182e9c109ff4)

> [!NOTE]
> Make sure you run `gh auth login` and authenticate with your github account to use the `gh` cli.

I recommend changing any settings again on the script file so they are written in there explicitly and can be restored after an experimentation.

### Devcontainer

From this point on I recommend working in a devcontainer, make sure docker deamon is running and then run the following command:

```bash
npm run dev
```

![demo](https://github.com/user-attachments/assets/01b907e7-91d0-4a4a-9ba2-9e829a2098d5)

This will create a volume for the devcontainer and start the devcontainer. To open a new vscode window inside the container run;

```bash
code --folder-uri vscode-remote://attached-container+67656e657269632d646576636f6e7461696e6572/home/monouser/workspace
```

> [!TIP]
> The id `67656e657269632d646576636f6e7461696e6572` is the name of the devcontainer (`generic-devcontainer`) in hex encoding.

Alternatively you can click `Open Remote Window` button or press `Ctrl+Shift+P` and select `Remote-Containers: Attach to Running Container...` to run the devcontainer.

![monorepo-1723561216300](https://github.com/user-attachments/assets/64dbbf7d-a930-4ea1-be15-b501179d7529)

Inside the devcontainer volume (`/home/monouser/workspace`) clone your repo and initialize;

```bash
gh auth login
git clone <your-repo-url>
cd <your-repo-name>
npm install
```

### Signing Key

If you want to sign your commits (enforced by default), [generate an SSH key](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification#ssh-commit-signature-verification) (steps 1-3) and run the following command:

```bash
npm run signingkey /path/to/signingkey.pub
```

### npm scripts

There are a few npm scripts that you can use to maintain your monorepo:

| Command (`npm run`)                        | Description                                                                          |
|------------------------------------------|--------------------------------------------------------------------------------------|
| reset-repo                     | Resets the repository to the default settings.                                               |
| update-from-template           | Updates the repository from the template (`arifbalik/monorepo`).                             |
| signingkey `path/to/signingkey.pub` | Configures git to use SSH signing key to sign commits.                                    |
| commitlint                     | Runs commitlint on the repository.                                                           |
| lint                           | Runs Megalinter on the repository.                                                           |
| dev                            | Starts the devcontainer (builds the image if it doesn't exist).                              |
| dev `-- --remove-existing-container` | Rebuilds the image and starts the devcontainer.                                          |
| dev-shell `<command>`            | Starts a shell in the devcontainer and runs the command.                                     |

> [!NOTE]
> Self hosted runners are not enabled by default. Please see [open pull request #8](https://github.com/arifbalik/monorepo/pull/8) to see how to enable them.
