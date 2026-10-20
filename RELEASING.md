# Releasing

## Versioning

The plugin version lives in `DateHierarchyExport.lrplugin/Info.lua`:

```lua
VERSION = { major = 1, minor = 0, revision = 0, build = 2 }
```

The Git tag is `v<major>.<minor>.<revision>`, for example `v1.0.0`. The `build`
field is for internal iteration and is not part of the tag.

## Release checklist

1. Update `VERSION` in `DateHierarchyExport.lrplugin/Info.lua`.
2. Verify the plugin still loads in Lightroom Classic.
3. Build the package:

   ```bash
   ./scripts/package.sh
   ```

   The script creates `dist/DateHierarchyExport-<version>.zip` and prints its
   SHA-256 checksum.

4. Unzip the archive and confirm it contains the plugin folder at the root.
5. Commit the version change:

   ```bash
   git add .
   git commit -m "Release v1.0.0"
   ```

6. Create and push the tag:

   ```bash
   git tag v1.0.0
   git push origin main --tags
   ```

7. The GitHub Actions workflow in `.github/workflows/release.yml` builds the
   zip and creates a GitHub Release with generated release notes.

## Manual release

If GitHub Actions is unavailable, create a GitHub Release manually and upload
the zip from `dist/`.

## Package layout

```text
DateHierarchyExport-1.0.0.zip
├── DateHierarchyExport.lrplugin/
├── README.md
└── README.zh-CN.md
```
