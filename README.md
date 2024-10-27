
# Supervisor

Supervisor is a Docker GitOps service that allows you to manage `docker-compose` based stacks through a REST API. The minimal input required to manage stacks includes a unique name, a URL to the git repository hosting the stack files, and a strategy for updating the stack (either via polling or webhook). Authentication and authorization are handled via HTTP headers.

## Status
[![GitHub Actions Workflow CI Status](https://img.shields.io/github/actions/workflow/status/tschaefer/supervisor/ci.yml?label=ci)](https://github.com/tschaefer/supervisor/actions)
[![GitHub Actions Workflow Docker Release Status](https://img.shields.io/github/actions/workflow/status/tschaefer/supervisor/docker-release.yml?label=docker-release)](https://github.com/tschaefer/supervisor/actions)

[![GitHub Release](https://img.shields.io/github/v/release/tschaefer/supervisor)](https://github.com/tschaefer/supervisor/releases/latest)
[![Container image](https://img.shields.io/badge/image-latest-blue)](https://github.com/tschaefer/supervisor/pkgs/container/supervisor/latest)

## Features

- Manage Docker Compose-based stacks via REST API
- GitOps strategy support:
  - **Polling**: Define an interval to automatically pull updates.
  - **Webhook**: Trigger updates via webhooks, with support for signatures.
- Supports Git repository authentication (username and token).
- Custom Docker Compose variables and additional Compose files can be passed with each stack.
- Secured with HTTP authorization headers.

## Requirements

- Docker must be installed on the host system.

## Running Supervisor

To run Supervisor as a Docker container:

```
docker container run --name supervisor \
  --detach \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --volume /var/lib/container/supervisor:/rails/storage \
  --env SUPERVISOR_SECRET_KEY_BASE="af8758d92e3eccfbcc84a6bd6684060d" \
  --env SUPERVISOR_API_KEY="8db7fde4-6a11-462e-ba27-6897b7c9281b" \
  --env SUPERVISOR_RAILS_LOG_LEVEL="info" \
  --publish 3000:3000 \
  ghcr.io/tschaefer/supervisor
```

### Exposing Port and HTTPS Requirements

- The Supervisor container exposes **port 3000** for HTTP traffic but **only accepts HTTPS connections**.
- You need to set up a reverse proxy (such as Nginx or Traefik) to handle HTTPS termination and forward traffic to the container on port 3000.

## REST API

You can interact with Supervisor via its REST API to manage stacks.

### Authentication

All requests to the API must be authorized using the `Authorization` HTTP header, which should contain the API key provided during setup.

```
--header "Authorization: Bearer <your-api-key>"
```

### API Endpoints

- **`POST /stacks`**: Create a new stack.
- **`GET /stacks`**: List all stacks.
- **`GET /stacks/<stack_uuid>`**: Show details of a specific stack.
- **`GET /stacks/<stack_uuid>/stats`**: Show statistics for a specific stack.
- **`PATCH/PUT /stacks/<stack_uuid>`**: Update a stack.
- **`DELETE /stacks/<stack_uuid>`**: Delete a stack.
- **`POST /stacks/<stack_uuid>/webhook`**: Trigger a stack update.
- **`GET /up`**: Check the health of the Supervisor service. (No authorization required)

### Creating a Stack

The following `curl` command demonstrates how to create a new stack using Supervisor's REST API:

```
curl --request POST \
  --silent \
  --header "Authorization: Bearer 8db7fde4-6a11-462e-ba27-6897b7c9281b" \
  --verbose \
  --json '{
    "name": "whoami",
    "git_repository": "https://github.com/tschaefer/infrastructure",
    "git_username": "tschaefer",
    "git_token": "github_pat_...FFF",
    "git_reference": "refs/heads/main",
    "compose_file": "lib/stack/whoami/docker-compose.yml",
    "compose_includes": [
      "lib/stack/whoami/includes/traefik.yml",
      "lib/stack/whoami/includes/network.yml"
    ],
    "compose_variables": {
      "NETWORK_IPV4_WHOAMI": "172.18.100.111",
      "NETWORK_ID": "core"
    },
    "strategy": "polling",
    "polling_interval": "300"
    "signature_header": "X-Hub-Signature-256",
    "signature_secret": "2ede1091492a7c4205ae9c0ee9ed7376
  }' \
  https://supervisor.example.com/stacks
```

#### Parameters

- `name`: Unique name for the stack.
- `git_repository`: URL to the git repository containing the stack's `docker-compose.yml` file.
- `git_username`: (Optional) Username for accessing the repository.
- `git_token`: (Optional) Token for accessing the repository.
- `git_reference`: Git reference (e.g., branch or tag) to track.
- `compose_file`: Path to the `docker-compose.yml` file in the repository.
- `compose_includes`: (Optional) A list of additional Compose files to be included.
- `compose_variables`: (Optional) Variables to pass to the compose file.
- `strategy`: GitOps strategy. Can be `polling` or `webhook`.
- `polling_interval`: (For `polling` strategy) Interval in seconds for polling the repository for changes.
- `signature_header` and `signature_secret`: (For `webhook` strategy) Additional data required for webhooks.

Any update beside the `name`, `strategy` and required attributes will apply a redeploy of the stack.

### List Stacks

To retrieve a list of all managed stacks:

```
curl --request GET \
  --silent \
  --header "Authorization: Bearer 8db7fde4-6a11-462e-ba27-6897b7c9281b" \
  --verbose \
  https://supervisor.example.com/stacks/
```

### Show Stack

To view the details of a specific stack (replace `<stack_uuid>` with the actual stack ID):

```
curl --request GET \
  --silent \
  --header "Authorization: Bearer 8db7fde4-6a11-462e-ba27-6897b7c9281b" \
  --verbose \
  https://supervisor.example.com/stacks/<stack_uuid>
```

### Show Stack Statistics

To view statistics for a specific stack, such as the number of processed or failed runs and the last run timestamp:

```
curl --request GET \
  --silent \
  --header "Authorization: Bearer 8db7fde4-6a11-462e-ba27-6897b7c9281b" \
  --verbose \
  https://supervisor.example.com/stacks/<stack_uuid>/stats
```

### Update Stack

To update a stack (e.g., changing the `strategy`):

```
curl --request PATCH \
  --silent \
  --header "Authorization: Bearer 8db7fde4-6a11-462e-ba27-6897b7c9281b" \
  --verbose \
  --json '{ "strategy": "webhook" }' \
  https://supervisor.example.com/stacks/<stack_uuid>
```

### Delete Stack

To delete a stack:

```
curl --request DELETE \
  --silent \
  --header "Authorization: Bearer 8db7fde4-6a11-462e-ba27-6897b7c9281b" \
  --verbose \
  https://supervisor.example.com/stacks/<stack_uuid>
```

## License

Supervisor is released under the [MIT License](https://opensource.org/licenses/MIT).
