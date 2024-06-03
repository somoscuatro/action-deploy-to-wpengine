# GitHub Action for WP Engine Git Deployments

Welcome to the official repository of the GitHub Action for WP Engine Git
Deployments. This action allows you to automatically deploy your WordPress
project to a [WP Engine](https://wpengine.com/) site via Git.

## Usage

1. Generate an SSH key for authentication between GitHub and WP Engine
1. Add the public SSH key to your WP Engine website environment: _Sites_ > _Your
   Website Environment_ > _GitPush_. See [Git Version Control System WP Engine
   documentation
   page](https://wpengine.com/support/git?_gl=1*11vkt9z*_ga*OTU0MzU3MTE2OC4xNjgxMjg0Nzc1*_ga_QQ5FN8NX8W*MTcxNzQxOTU0Mi4xMC4xLjE3MTc0MTk3NjQuMC4wLjI5MTg0NDY1MQ..#Create_SSH_Config)
1. In your GitHub Repository settings, create new Secrets for the SSH Private
   (`WPENGINE_SSH_PRIVATE_KEY`) and Public keys (`WPENGINE_SSH_PUBLIC_KEY`). See
   [Adding secrets for a repository
   documentation](https://wpengine.com/support/git?_gl=1*11vkt9z*_ga*OTU0MzU3MTE2OC4xNjgxMjg0Nzc1*_ga_QQ5FN8NX8W*MTcxNzQxOTU0Mi4xMC4xLjE3MTc0MTk3NjQuMC4wLjI5MTg0NDY1MQ..#Create_SSH_Config)
1. Create a workflow file in your project repo, for example
   `.github/workflows/deploy.yml`
1. Add the following code to the workflow file you just created:

    ```yml
    name: Deploy to WP Engine

    on:
      # In this example we are deploying to WP Engine when a new release is published.
      # You can change this to be on PR merge, push to a given branch, etc.
      # See https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows
      release:
        types: [published]

    jobs:
      build:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v3
            name: Checkout repository
            with:
              fetch-depth: 0

          # Do your things here.
          # For example install dependencies, build assets before deploying, etc.

          - name: Deploy
            uses: somoscuatro/action-deploy-to-wpengine
            env:
              WPENGINE_SSH_PRIVATE_KEY: ${{ secrets.WPENGINE_SSH_PRIVATE_KEY }}
              WPENGINE_SSH_PUBLIC_KEY: ${{ secrets.WPENGINE_SSH_PUBLIC_KEY }}
              WPENGINE_ENVIRONMENT_NAME: production # Defaults to production. Adjust to match your WP Engine environment name, if needed.
    ```

1. If you want to exclude some files to be deployed, create a
   `.github/workflows/deploy/excluded` file in your project repo containing
   untracked files and folders that WP Engine should ignore. For example:

    ```yml
    .vscode
    .docker
    docker-compose.yml
    .env
    ```

## Environment Variables & Secrets

### Required

| Name                        | Type                 | Required | Usage                                                                           |
| --------------------------- | -------------------- | -------- | ------------------------------------------------------------------------------- |
| `WPENGINE_SSH_PRIVATE_KEY`  | Secret               | Yes      | Private SSH key of your WP Engine git deploy user. See below for SSH key usage. |
| `WPENGINE_SSH_PUBLIC_KEY`   | Secret               | Yes      | Public SSH key of your WP Engine git deploy user. See below for SSH key usage.  |
| `WPENGINE_ENVIRONMENT_NAME` | Environment Variable | No       | Defaults to `production`.                                                       |

## How to Contribute

Any kind of contribution is very welcome!

Please, be sure to read our Code of Conduct.

If you notice something wrong please open an issue or create a Pull Request or
just send an email to [tech@somoscuatro.es](mailto:tech@somoscuatro.es). If you
want to warn us about an important security vulnerability, please read our
Security Policy.

## License

All code is released under MIT license version. For more information, please
refer to
[LICENSE.md](https://github.com/somoscuatro/action-deploy-to-wpengine/blob/main/LICENSE)
file.
