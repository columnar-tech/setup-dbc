# Setup dbc Action

GitHub Action to install the [dbc CLI](https://dbc.columnar.tech), authenticate with optional API key, and install drivers.

## Features

- 🚀 Fast installation using official dbc install scripts
- 💾 Automatic caching for faster subsequent runs
- 🔑 Optional API key authentication for private drivers
- 📦 Driver installation via explicit list or config file
- 🖥️ Cross-platform support (Linux, macOS, Windows)
- 📌 Version pinning for reproducible builds

## Usage

### Basic Setup

Install the latest version of dbc CLI:

```yaml
steps:
  - uses: actions/checkout@v4
  - uses: columnar-tech/setup-dbc@v1
  - run: dbc --version
```

### With Specific Version

Pin to a specific version for reproducibility:

```yaml
steps:
  - uses: columnar-tech/setup-dbc@v1
    with:
      version: 'v0.2.0'
```

### With Driver Installation

Install drivers using a comma-separated list:

```yaml
steps:
  - uses: columnar-tech/setup-dbc@v1
    with:
      drivers: 'postgresql,mysql,sqlite'
```

### With Private Drivers

Authenticate with API key for private drivers:

```yaml
steps:
  - uses: columnar-tech/setup-dbc@v1
    with:
      api-key: ${{ secrets.DBC_API_KEY }}
      drivers: 'oracle,teradata,postgresql'
```

### Using Config File

Install drivers from a `dbc.toml` file:

```yaml
steps:
  - uses: actions/checkout@v4
  - uses: columnar-tech/setup-dbc@v1
    with:
      driver-list-file: 'dbc.toml'
```

### Custom Config File Path

```yaml
steps:
  - uses: actions/checkout@v4
  - uses: columnar-tech/setup-dbc@v1
    with:
      driver-list-file: 'config/custom-dbc.toml'
```

### Skip Driver Installation

Install only the CLI without drivers:

```yaml
steps:
  - uses: columnar-tech/setup-dbc@v1
    with:
      skip-drivers: 'true'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `version` | Version of dbc CLI to install (e.g., `v0.2.0` or `latest`) | No | `latest` |
| `api-key` | API key for authenticating private driver installations | No | - |
| `drivers` | Comma-separated list of drivers to install | No | - |
| `driver-list-file` | Path to dbc.toml config file for driver installation | No | `dbc.toml` |
| `skip-drivers` | Skip driver installation even if drivers specified | No | `false` |

## Outputs

| Output | Description |
|--------|-------------|
| `version` | The installed version of dbc CLI |
| `cache-hit` | Whether the dbc CLI was restored from cache |

## Driver Installation Priority

If both `drivers` and `driver-list-file` inputs are provided, the explicit `drivers` list takes precedence.

## Caching

This action automatically caches the dbc CLI binary based on the version and OS. Subsequent runs with the same version will be significantly faster.

## Error Handling

- **Exit code 1**: CLI installation failed
- **Exit code 2**: Driver installation failed (CLI installed successfully)

This allows you to differentiate between CLI and driver failures in your workflows.

## Examples

### Complete Workflow

```yaml
name: Test Database
on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: columnar-tech/setup-dbc@v1
        with:
          version: 'v0.2.0'
          drivers: 'postgresql,mysql'

      - name: Run tests
        run: npm test
```

### Matrix Testing

Test against multiple driver versions:

```yaml
name: Matrix Test
on: [push]

jobs:
  test:
    strategy:
      matrix:
        driver: [postgresql, mysql, sqlite]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: columnar-tech/setup-dbc@v1
        with:
          drivers: ${{ matrix.driver }}

      - run: npm test
```

## License

Apache-2.0
