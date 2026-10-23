# NextStep for macOS

A native SwiftUI job-search workspace for tracking multiple applications, networking, recruiting signals, and interview preparation.

## Launch the app

Double-click `NextStep.app` in this folder.

To rebuild it after changing the source:

```bash
./build-app.sh
```

The source is a Swift Package and can also be opened in Xcode by opening `Package.swift`.

## Integration status

- Interview preparation uses Apple's Foundation Models framework on-device, with a local deterministic fallback if Apple Intelligence is unavailable.
- Gmail and LinkedIn screens currently use clearly labeled demo signals. Real access requires provider OAuth credentials, a secure token service, and—particularly for LinkedIn—approved API access.
