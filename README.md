# Date Hierarchy Export

[English](README.md) | [简体中文](README.zh-CN.md)

A Lightroom Classic export plugin that writes exported photos into a
`year/year-month-day` folder hierarchy based on each photo's capture date,
making it easy to archive by shoot and sync to cloud storage.

## The problem it solves

Lightroom Classic's built-in "Put in subfolder" option only accepts fixed text.
It cannot expand a capture date per photo or create multi-level date folders
directly. This plugin adds an export service that reads each photo's capture
time during export and builds a path like:

```text
/Users/jelly/Pictures/LightroomExport/2025/2025-10-11/20251011_163626_DSC00692.jpg
```

The file name is still controlled by Lightroom's "File Naming" settings; the
plugin only handles the destination folder.

## Features

- Automatically creates `YYYY/YYYY-MM-DD` folders based on capture date.
- Customizable folder pattern, for example `%Y/%Y-%m-%d`, `%Y/%m`, or `%Y-%m-%d`.
- Choose to skip photos with no capture date or use the export time.
- Choose to skip or overwrite existing files.
- English, Simplified Chinese, and Traditional Chinese UI.
- Writes an export log for troubleshooting.

## Installation

The plugin is the `DateHierarchyExport.lrplugin` folder in this repository. The
project can live wherever you like; Lightroom loads the plugin from the location
you choose.

### Option 1: Plug-in Manager

1. Open `File > Plug-in Manager...` in Lightroom Classic.
2. Click `Add`.
3. Select `DateHierarchyExport.lrplugin`.
4. Click `Done`, then restart Lightroom Classic.

### Option 2: Modules folder

Lightroom Classic also loads plugins automatically from its Modules folder.

On macOS, run this from the repository root:

```bash
mkdir -p "$HOME/Library/Application Support/Adobe/Lightroom/Modules"
ln -sfn "$PWD/DateHierarchyExport.lrplugin" \
  "$HOME/Library/Application Support/Adobe/Lightroom/Modules/DateHierarchyExport.lrplugin"
```

On Windows, run this from the repository root in PowerShell:

```powershell
New-Item -ItemType Directory -Force "$env:APPDATA\Adobe\Lightroom\Modules" | Out-Null
New-Item -ItemType Junction `
  -Path "$env:APPDATA\Adobe\Lightroom\Modules\DateHierarchyExport.lrplugin" `
  -Target "$PWD\DateHierarchyExport.lrplugin"
```

Alternatively, copy the `DateHierarchyExport.lrplugin` folder into:

- macOS: `~/Library/Application Support/Adobe/Lightroom/Modules/`
- Windows: `%APPDATA%\Adobe\Lightroom\Modules\`

Restart Lightroom Classic after installing.

If you move the project folder later, re-add the plugin in the Plug-in Manager
or update the link.

## Usage

1. Select photos in Lightroom and open Export.
2. In the "Export To" drop-down, choose **Date Hierarchy Export**.
3. Confirm the destination folder and folder pattern.
4. Configure file format, quality, file naming, and other usual settings.
5. Click Export.

Note: do not choose "Export To: Hard Drive". That is Lightroom's built-in export
service and will not invoke this plugin, so all files will end up flat in one
folder.

Also, if you use Lightroom's built-in "Hard Drive" export, make sure "Add to
Catalog" is unchecked. Adding exported JPGs back into the catalog makes them
appear in Lightroom unnecessarily and easily confuses them with the original RAW
files. This plugin hides the native "Export Location" section by default; if you
still see "Add to Catalog", leave it unchecked.

## Folder pattern

Default destination:

```text
/Users/jelly/Pictures/LightroomExport
```

Default folder pattern:

```text
%Y/%Y-%m-%d
```

Common patterns:

| Pattern | Result |
| --- | --- |
| `%Y/%Y-%m-%d` | `2025/2025-10-11` |
| `%Y/%m` | `2025/10` |
| `%Y-%m-%d` | `2025-10-11` |
| `%Y/%Y-%m` | `2025/2025-10` |

A `/` in the pattern creates a subfolder. The plugin uses the photo's capture
time, not the file modification time.

## About the destination

Exported JPGs are derivative files, so it is best to keep them separate from the
RAW originals. The default is `/Users/jelly/Pictures/LightroomExport` rather than
inside `Pictures/Photography`, so cloud backups do not mix exports with original
material and Lightroom's Folders panel stays cleaner. To export directly to an
SSD or a cloud-synced folder, change the plugin's "Destination" setting.

## Options

**Missing capture date**

- Skip: do not export that photo and report it at the end.
- Use export time: file it under the time of this export.

**If file exists**

- Skip: keep the existing file and report it at the end.
- Overwrite: delete the old file and write the new one.

## Localization

The plugin uses Lightroom's Z-string localization:

- English: built into `Info.lua` and `ExportServiceProvider.lua`.
- Simplified Chinese: `TranslatedStrings_zh_cn.txt`
- Traditional Chinese: `TranslatedStrings_zh_tw.txt`

Lightroom loads the matching file based on the current UI language. Restart
Lightroom after changing translations.

Translation files are not plain `key=value` text. Every line must be a complete,
double-quoted Z-string, for example:

```text
"$$$/DateHierarchyExport/Skip=跳过"
```

The leading and trailing quotes are required. Without them, Lightroom reports a
ZString format error and falls back to English entirely.

## Project structure

```text
lightroom-date-hierarchy-export/
├── README.md
├── README.zh-CN.md
└── DateHierarchyExport.lrplugin/
    ├── Info.lua
    ├── ExportServiceProvider.lua
    ├── TranslatedStrings_zh_cn.txt
    └── TranslatedStrings_zh_tw.txt
```

## Troubleshooting

**Exported files are still all in one flat folder**

Check whether "Export To" is set to "Hard Drive". You must choose "Date Hierarchy
Export".

**The plugin does not appear in the list**

Confirm the `.lrplugin` path is correct, then add it again in the Plug-in Manager
and restart Lightroom.

**The UI is still in English**

First confirm Lightroom's UI language is Simplified or Traditional Chinese, then
check that every line in the corresponding translation file is double-quoted.
Fully quit and restart Lightroom after editing translation files.

**Exported photos appear in the Lightroom catalog**

"Add to Catalog" was enabled. When removing these exported photos, choose
"Remove from Catalog", not "Delete from Disk".

**Where are the logs**

Lightroom Classic usually writes `LrLogger` output to:

```text
~/Documents/LrClassicLogs/DateHierarchyExport.log
```

**Does this plugin back up RAW files**

No. It only files Lightroom exports into date-based folders. Backing up RAW
originals, the Lightroom catalog, and editing sources needs to be handled
separately.
