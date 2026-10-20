local LrDate = import 'LrDate'
local LrDialogs = import 'LrDialogs'
local LrFileUtils = import 'LrFileUtils'
local LrLogger = import 'LrLogger'
local LrPathUtils = import 'LrPathUtils'
local LrView = import 'LrView'

local logger = LrLogger('DateHierarchyExport')
logger:enable('logfile')

local DEFAULT_DESTINATION = '/Users/jelly/Pictures/LightroomExport'
local DEFAULT_PATTERN = '%Y/%Y-%m-%d'

local function loc(key, fallback)
	return LOC('$$$/DateHierarchyExport/' .. key .. '=' .. fallback)
end

local function joinParts(parts)
	return table.concat(parts, '/')
end

local function relativeFolderFor(timestamp, pattern)
	local relative = LrDate.timeToUserFormat(timestamp, pattern)
	relative = relative:gsub('\\', '/'):gsub(':', '-')

	local parts = {}
	for part in relative:gmatch('[^/]+') do
		if part ~= '' and part ~= '.' and part ~= '..' then
			table.insert(parts, part)
		end
	end

	return joinParts(parts)
end

local function updateStatus(propertyTable)
	local message = nil

	if propertyTable.destPath == nil or propertyTable.destPath == '' then
		message = loc('NoDestination', 'Choose a destination folder.')
	elseif propertyTable.dateFormat == nil or propertyTable.dateFormat == '' then
		message = loc('NoPattern', 'Enter a folder date pattern.')
	end

	propertyTable.LR_cantExportBecause = message
end

local function sectionsForBottomOfDialog(f, propertyTable)
	local bind = LrView.bind
	local share = LrView.share

	return {
		{
			title = loc('SectionTitle', 'Date Hierarchy'),
			f:row {
				f:static_text {
					title = loc('Destination', 'Destination:'),
					alignment = 'right',
					width = share 'labelWidth',
				},
				f:static_text {
					title = bind 'destPath',
					truncation = 'head',
					width = 390,
				},
				f:push_button {
					title = loc('Browse', 'Browse...'),
					action = function()
						local result = LrDialogs.runOpenPanel {
							title = loc('SelectDestination', 'Select Export Destination'),
							prompt = loc('Choose', 'Choose'),
							initialDirectory = propertyTable.destPath,
							canChooseFiles = false,
							canChooseDirectories = true,
							canCreateDirectories = true,
							allowsMultipleSelection = false,
						}
						if result then
							propertyTable.destPath = result[1]
						end
					end,
				},
			},
			f:row {
				f:static_text {
					title = loc('FolderPattern', 'Folder pattern:'),
					alignment = 'right',
					width = share 'labelWidth',
				},
				f:edit_field {
					value = bind 'dateFormat',
					immediate = true,
					width = 420,
					wraps = false,
					tooltip = loc(
						'FolderPatternTooltip',
						'Uses capture time. Example: %Y/%Y-%m-%d'
					),
				},
			},
			f:row {
				f:static_text {
					title = loc('Example', 'Example:'),
					alignment = 'right',
					width = share 'labelWidth',
				},
				f:static_text {
					title = bind {
						key = 'dateFormat',
						transform = function(value)
							return LrDate.timeToUserFormat(
								LrDate.currentTime(),
								value or DEFAULT_PATTERN
							)
						end,
					},
				},
			},
			f:row {
				f:static_text {
					title = loc('MissingDate', 'Missing capture date:'),
					alignment = 'right',
					width = share 'labelWidth',
				},
				f:radio_button {
					title = loc('Skip', 'Skip'),
					value = bind 'missingDate',
					checked_value = 'skip',
				},
				f:radio_button {
					title = loc('UseExportTime', 'Use export time'),
					value = bind 'missingDate',
					checked_value = 'current',
				},
			},
			f:row {
				f:static_text {
					title = loc('IfExists', 'If file exists:'),
					alignment = 'right',
					width = share 'labelWidth',
				},
				f:radio_button {
					title = loc('Skip', 'Skip'),
					value = bind 'ifExists',
					checked_value = 'skip',
				},
				f:radio_button {
					title = loc('Overwrite', 'Overwrite'),
					value = bind 'ifExists',
					checked_value = 'overwrite',
				},
			},
		},
	}
end

local function processRenderedPhotos(functionContext, exportContext)
	local exportSession = exportContext.exportSession
	local params = exportContext.propertyTable
	local destination = params.destPath
	local pattern = params.dateFormat
	local missingDate = params.missingDate or 'skip'
	local ifExists = params.ifExists or 'skip'
	local pluginTitle = loc('PluginName', 'Date Hierarchy Export')

	if destination == nil or destination == '' then
		LrDialogs.message(
			pluginTitle,
			loc('NoDestination', 'Choose a destination folder.'),
			'critical'
		)
		return
	end

	if pattern == nil or pattern == '' then
		LrDialogs.message(
			pluginTitle,
			loc('NoPattern', 'Enter a folder date pattern.'),
			'critical'
		)
		return
	end

	local count = exportSession:countRenditions()
	local title
	if count == 1 then
		title = loc('ExportingOne', 'Exporting 1 photo...')
	else
		title = string.format(
			loc('ExportingMany', 'Exporting %d photos...'),
			count
		)
	end
	local progress = exportContext:configureProgress { title = title }
	local failures = {}

	logger:info(
		'processRenderedPhotos: destination=' .. tostring(destination)
		.. ' pattern=' .. tostring(pattern)
		.. ' count=' .. tostring(count)
	)

	for _, rendition in exportContext:renditions { stopIfCanceled = true } do
		local success, pathOrMessage = rendition:waitForRender()

		if progress:isCanceled() then
			break
		end

		if not success then
			table.insert(failures, tostring(pathOrMessage))
		else
			local filename = LrPathUtils.leafName(pathOrMessage)
			local timestamp = rendition.photo:getRawMetadata('dateTimeOriginal')

			if timestamp == nil or timestamp == '' then
				timestamp = rendition.photo:getRawMetadata('dateTimeDigitized')
			end

			if (timestamp == nil or timestamp == '') and missingDate == 'current' then
				timestamp = LrDate.currentTime()
			end

			if timestamp == nil or timestamp == '' then
				table.insert(
					failures,
					filename .. ' (' .. loc('MissingCaptureDate', 'missing capture date') .. ')'
				)
				LrFileUtils.delete(pathOrMessage)
			else
				local relativeFolder = relativeFolderFor(timestamp, pattern)

				if relativeFolder == '' then
					table.insert(
						failures,
						filename .. ' (' .. loc('EmptyFolderPattern', 'empty folder pattern') .. ')'
					)
					LrFileUtils.delete(pathOrMessage)
				else
					local targetFolder = LrPathUtils.child(destination, relativeFolder)
					LrFileUtils.createAllDirectories(targetFolder)

					if not LrFileUtils.exists(targetFolder) then
						table.insert(
							failures,
							filename .. ' (' .. loc('CannotCreateFolder', 'cannot create folder') .. ')'
						)
						LrFileUtils.delete(pathOrMessage)
					else
						local targetPath = LrPathUtils.child(targetFolder, filename)
						local shouldCopy = true

						if LrFileUtils.exists(targetPath) then
							if ifExists == 'overwrite' then
								local deleted, reason = LrFileUtils.delete(targetPath)
								if not deleted then
									table.insert(failures, filename .. ' (' .. tostring(reason) .. ')')
									shouldCopy = false
								end
							else
								table.insert(
									failures,
									filename .. ' (' .. loc('AlreadyExists', 'already exists') .. ')'
								)
								shouldCopy = false
							end
						end

						if shouldCopy then
							local copied, reason = LrFileUtils.copy(pathOrMessage, targetPath)
							if not copied then
								table.insert(failures, filename .. ' (' .. tostring(reason) .. ')')
							else
								logger:info('exported ' .. filename .. ' -> ' .. targetPath)
							end
						end

						LrFileUtils.delete(pathOrMessage)
					end
				end
			end
		end
	end

	if #failures > 0 then
		LrDialogs.message(
			pluginTitle,
			table.concat(failures, '\n'),
			'warning'
		)
	end
end

return {
	hideSections = { 'exportLocation' },
	allowFileFormats = nil,
	allowColorSpaces = nil,
	canExportVideo = true,

	exportPresetFields = {
		{ key = 'destPath', default = DEFAULT_DESTINATION },
		{ key = 'dateFormat', default = DEFAULT_PATTERN },
		{ key = 'missingDate', default = 'skip' },
		{ key = 'ifExists', default = 'skip' },
	},

	startDialog = function(propertyTable)
		propertyTable:addObserver('destPath', updateStatus)
		propertyTable:addObserver('dateFormat', updateStatus)
		updateStatus(propertyTable)
	end,

	sectionsForBottomOfDialog = sectionsForBottomOfDialog,
	processRenderedPhotos = processRenderedPhotos,
}
