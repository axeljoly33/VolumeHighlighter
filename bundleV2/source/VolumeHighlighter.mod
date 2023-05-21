return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`VolumeHighlighter` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("VolumeHighlighter", {
			mod_script       = "scripts/mods/VolumeHighlighter/VolumeHighlighter",
			mod_data         = "scripts/mods/VolumeHighlighter/VolumeHighlighter_data",
			mod_localization = "scripts/mods/VolumeHighlighter/VolumeHighlighter_localization",
		})
	end,
	packages = {
		"resource_packages/VolumeHighlighter/VolumeHighlighter",
	},
}
