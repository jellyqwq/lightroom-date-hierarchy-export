# Date Hierarchy Export

[English](README.md) | 简体中文

一个 Lightroom Classic 导出插件：按照片的拍摄日期，把导出的照片自动写入
`年/年-月-日` 的多级目录，方便按次归档和同步到网盘。

## 它解决什么问题

Lightroom Classic 原生导出对话框里的“放入子文件夹”只能填写固定文本，
不能针对每张照片展开拍摄日期，也无法直接生成多级日期目录。这个插件新增了
一个导出服务，在导出时读取每张照片的拍摄时间，并生成类似下面的路径：

```text
/Users/jelly/Pictures/LightroomExport/2025/2025-10-11/20251011_163626_DSC00692.jpg
```

文件名仍然由 Lightroom 的“文件命名”设置决定；插件只负责目标目录。

## 功能

- 按拍摄日期自动建立 `YYYY/YYYY-MM-DD` 目录。
- 目录格式可自定义，例如 `%Y/%Y-%m-%d`、`%Y/%m` 或 `%Y-%m-%d`。
- 拍摄日期缺失时，可选择跳过或使用导出时间。
- 目标文件已存在时，可选择跳过或覆盖。
- 支持简体中文、繁体中文和英文界面。
- 导出过程写入日志，便于排查。

## 安装

插件就是仓库里的 `DateHierarchyExport.lrplugin` 文件夹。项目放在哪里都可以，
Lightroom 会从你选择的位置加载插件。

### 方式一：增效工具管理器

1. 打开 Lightroom Classic 的 `文件 > 增效工具管理器...`。
2. 点击 `添加`。
3. 选择 `DateHierarchyExport.lrplugin`。
4. 点击 `完成`，然后重启 Lightroom Classic。

### 方式二：放入 Modules 目录

Lightroom Classic 也会自动加载 Modules 目录中的插件。

macOS，在仓库根目录执行：

```bash
mkdir -p "$HOME/Library/Application Support/Adobe/Lightroom/Modules"
ln -sfn "$PWD/DateHierarchyExport.lrplugin" \
  "$HOME/Library/Application Support/Adobe/Lightroom/Modules/DateHierarchyExport.lrplugin"
```

Windows，在仓库根目录用 PowerShell 执行：

```powershell
New-Item -ItemType Directory -Force "$env:APPDATA\Adobe\Lightroom\Modules" | Out-Null
New-Item -ItemType Junction `
  -Path "$env:APPDATA\Adobe\Lightroom\Modules\DateHierarchyExport.lrplugin" `
  -Target "$PWD\DateHierarchyExport.lrplugin"
```

也可以直接把 `DateHierarchyExport.lrplugin` 文件夹复制到：

- macOS：`~/Library/Application Support/Adobe/Lightroom/Modules/`
- Windows：`%APPDATA%\Adobe\Lightroom\Modules\`

安装后重启 Lightroom Classic。

如果以后移动了项目目录，需要在增效工具管理器里重新添加插件，或更新链接。

## 使用

1. 在 Lightroom 中选好照片，打开“导出”。
2. 在“导出到”下拉框中选择 **日期层级导出 / Date Hierarchy Export**。
3. 确认目标文件夹和文件夹格式。
4. 选择文件格式、画质、文件命名等常规设置。
5. 点击“导出”。

注意：不要选择“导出到：硬盘”。那是 Lightroom 自带的导出服务，不会调用这个插件，
结果就会全部平铺在同一个目录里。

另外，如果使用 Lightroom 自带的“硬盘”导出，务必取消勾选“添加到目录”。把导出的
JPG 重新加入目录会让它们出现在 Lightroom 里，既没有必要，也容易和原始 RAW 混淆。
插件导出默认隐藏了原生“导出位置”区域；如果你仍然看到“添加到目录”，请取消勾选。

## 目录格式

默认目标文件夹：

```text
/Users/jelly/Pictures/LightroomExport
```

默认文件夹格式：

```text
%Y/%Y-%m-%d
```

常用格式：

| 格式 | 结果 |
| --- | --- |
| `%Y/%Y-%m-%d` | `2025/2025-10-11` |
| `%Y/%m` | `2025/10` |
| `%Y-%m-%d` | `2025-10-11` |
| `%Y/%Y-%m` | `2025/2025-10` |

格式中的 `/` 会创建子目录。插件使用照片的“拍摄时间”，不是文件修改时间。

## 关于目录位置

导出 JPG 属于派生文件，建议和 RAW 原片目录分开存放。默认放在
`/Users/jelly/Pictures/LightroomExport`，而不是 `Pictures/Photography` 里面，
这样备份网盘时不会把导出文件和原始素材混在一起，Lightroom 的文件夹面板也更干净。
如果想把导出直接放到 SSD 或网盘同步目录，在插件的“目标文件夹”里改即可。

## 选项

**缺少拍摄日期**

- 跳过：不导出该照片，并在结束时提示。
- 使用导出时间：按本次导出的时间归档。

**文件已存在时**

- 跳过：保留已有文件，并在结束时提示。
- 覆盖：删除旧文件后写入新文件。

## 多语言

插件使用 Lightroom 的 Z-string 本地化机制：

- 英文：内置在 `Info.lua` 和 `ExportServiceProvider.lua` 中。
- 简体中文：`TranslatedStrings_zh_cn.txt`
- 繁体中文：`TranslatedStrings_zh_tw.txt`

Lightroom 会根据当前界面语言自动加载对应文件。修改翻译后需要重启 Lightroom。

翻译文件不是普通的 `key=value` 文本。每一行都必须是一个完整的、带双引号的 Z-string，例如：

```text
"$$$/DateHierarchyExport/Skip=跳过"
```

行首和行尾的引号不能省略。缺少引号时 Lightroom 会报 ZString 格式错误，并整体回退到英文。

## 项目结构

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

## 常见问题

**导出后文件还是全部平铺**

检查“导出到”是否选成了“硬盘”。必须选择“日期层级导出 / Date Hierarchy Export”。

**插件列表里看不到**

确认 `.lrplugin` 路径正确，然后在“增效工具管理器”中重新添加并重启 Lightroom。

**界面没有变成中文**

先确认 Lightroom 的界面语言是简体中文或繁体中文，再检查对应翻译文件的每一行是否带双引号。修改翻译文件后需要完全退出并重新启动 Lightroom。

**导出的照片出现在 Lightroom 目录里**

这是勾选了“添加到目录”。移除这些导出照片时选择“从目录中移除”，不要选择
“从磁盘删除”。

**想看日志**

Lightroom Classic 通常会把 `LrLogger` 的日志写到：

```text
~/Documents/LrClassicLogs/DateHierarchyExport.log
```

**这个插件会备份 RAW 吗**

不会。它只负责把 Lightroom 导出的文件按日期放进目录。RAW 原片、Lightroom 目录和
修图源文件的备份需要单独安排。
