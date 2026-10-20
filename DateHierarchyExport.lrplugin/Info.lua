-- Lightroom Classic export service for date-based destination folders.

return {
	LrSdkVersion = 14.0,
	LrSdkMinimumVersion = 6.0,

	LrToolkitIdentifier = 'local.jelly.datehierarchy',
	LrPluginName = LOC('$$$/DateHierarchyExport/PluginName=Date Hierarchy Export'),

	LrExportServiceProvider = {
		title = LOC('$$$/DateHierarchyExport/ServiceTitle=Date Hierarchy Export'),
		file = 'ExportServiceProvider.lua',
	},

	VERSION = { major = 1, minor = 0, revision = 0, build = 2 },
}
