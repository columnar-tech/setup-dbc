# Setup DBC Action

GitHub Action to install the [dbc CLI](https://dbc.how), authenticate with optional API key, and install drivers.

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
  - uses: zeroshade/setup-dbc@v1
  - run: dbc version
```

### With Specific Version

Pin to a specific version for reproducibility:

```yaml
steps:
  - uses: zeroshade/setup-dbc@v1
    with:
      version: 'v1.2.3'
```

### With Driver Installation

Install drivers using a comma-separated list:

```yaml
steps:
  - uses: zeroshade/setup-dbc@v1
    with:
      drivers: 'postgres,mysql,sqlite'
```

### With Private Drivers

Authenticate with API key for private drivers:

```yaml
steps:
  - uses: zeroshade/setup-dbc@v1
    with:
      api-key: ${{ secrets.DBC_API_KEY }}
      drivers: 'private-driver,postgres'
```

### Using Config File

Install drivers from a `dbc.toml` file:

```yaml
steps:
  - uses: actions/checkout@v4
  - uses: zeroshade/setup-dbc@v1
    with:
      config-file: 'dbc.toml'
```

### Custom Config File Path

```yaml
steps:
  - uses: actions/checkout@v4
  - uses: zeroshade/setup-dbc@v1
    with:
      config-file: 'config/custom-dbc.toml'
```

### Skip Driver Installation

Install only the CLI without drivers:

```yaml
steps:
  - uses: zeroshade/setup-dbc@v1
    with:
      skip-drivers: 'true'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `version` | Version of dbc CLI to install (e.g., `v1.2.3` or `latest`) | No | `latest` |
| `api-key` | API key for authenticating private driver installations | No | - |
| `drivers` | Comma-separated list of drivers to install | No | - |
| `config-file` | Path to dbc.toml config file for driver installation | No | `dbc.toml` |
| `skip-drivers` | Skip driver installation even if drivers specified | No | `false` |

## Outputs

| Output | Description |
|--------|-------------|
| `version` | The installed version of dbc CLI |
| `cache-hit` | Whether the dbc CLI was restored from cache |

## Driver Installation Priority

If both `drivers` and `config-file` inputs are provided, the explicit `drivers` list takes precedence.

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

      - uses: zeroshade/setup-dbc@v1
        with:
          version: 'v1.2.3'
          drivers: 'postgres,mysql'

      - name: Run database tests
        run: |
          dbc start postgres
          npm test
          dbc stop
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
        driver: [postgres, mysql, sqlite]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: zeroshade/setup-dbc@v1
        with:
          drivers: ${{ matrix.driver }}

      - run: dbc start ${{ matrix.driver }}
      - run: npm test
```

## License

MIT
