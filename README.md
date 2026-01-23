# Exo Tech Anchor Template

A template repository for Solana programs using Anchor, with LiteSVM integration tests and a Codama-generated Rust client SDK.

## Features

- **Anchor 0.31.1** program scaffold
- **LiteSVM** integration tests for fast, local testing
- **Codama** auto-generated Rust client SDK
- **GitHub Actions** CI workflow

## Project Structure

```
├── programs/                 # Anchor programs
├── clients/rust/             # Generated Rust client SDK
├── integration-tests/        # LiteSVM-based tests
├── scripts/
│   ├── generate-clients.mjs  # Regenerate client SDK
│   └── rename-project.sh     # Rename the project
└── .github/workflows/        # CI configuration
```

## Getting Started

### 1. Use this template

Click "Use this template" on GitHub or clone the repository.

### 2. Rename the project

```bash
./scripts/rename-project.sh your-project-name
```

This updates all references and deletes itself when complete.

### 3. Update this README

Replace this content with documentation for your project.

### 4. Build and test

```bash
anchor build
yarn generate:clients
cargo test
```

## Development

### Build the program

```bash
anchor build
```

### Regenerate the client SDK

```bash
yarn generate:clients
```

### Run tests

```bash
cargo test
```

### Format code

```bash
cargo +nightly fmt --all
```
