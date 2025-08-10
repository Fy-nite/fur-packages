# Purr Packages

Welcome to the official Purr packages repository!

This repository contains the default set of essential packages and build scripts for the Purr package manager. These packages are designed to bootstrap a new system with the core tools needed for development and further package management.

## Repository Structure

Each package is organized as a separate folder under relevant categories. Inside each package folder, you will find installation scripts (typically PowerShell `.ps1` files) and any supporting files needed to build or install the package. These scripts are also published individually on the Purr package manager website, allowing users to download and install packages as needed.

Example structure:

```
category/
	package-name/
		install.ps1
		...other files...
```

## What’s Included?

This repository provides build scripts and package definitions for foundational tools, such as:

- GCC (GNU Compiler Collection)
- Make
- Clang
- .NET SDK
- Git
- Curl
- And more essential utilities

These packages are intended as the minimal set required to get a system up and running with Purr, enabling users to build and install additional software.

## Getting Started

1. Browse the repository to find the package you need under its category.
2. Download the relevant install script (e.g., `install.ps1`) from the package folder, either from this repository or directly from the Purr package manager website.
3. Run the install script using PowerShell to build or install the package on your system.
4. Follow any additional instructions provided in the package folder or script comments.

## Contributing

Contributions are welcome! If you’d like to add a new package or improve existing scripts, please open a pull request or issue.

## License

AGPL