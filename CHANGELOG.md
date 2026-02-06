# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0]

### Added

- Initial release
- Roda plugin with `plugin :inertia` registration
- `inertia` method for rendering Inertia responses (JSON for XHR, full HTML for initial loads)
- `inertia_share` for shared data across requests
- `inertia_redirect` with 303 status and external URL support
- Asset version checking with 409 on mismatch
- HTML escaping to prevent XSS in page data
- Full HTML page rendering through layout system
- Example apps for React and Svelte

[0.1.0]: https://github.com/holamendi/inertia-roda/releases/tag/v0.1.0
