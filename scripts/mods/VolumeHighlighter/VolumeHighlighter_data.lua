local mod = get_mod("VolumeHighlighter")

return {
	name = "Volume Highlighter",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
            {
				setting_id      = "highlight_collision",
				type            = "keybind",
				default_value   = {},
				keybind_trigger = "pressed",
				keybind_type    = "function_call",
				function_name   = "highlight_collision"
			},
            {
				setting_id      = "highlight_dw",
				type            = "keybind",
				default_value   = {},
				keybind_trigger = "pressed",
				keybind_type    = "function_call",
				function_name   = "highlight_dw"
			},
            {
				setting_id      = "remove_highlights",
				type            = "keybind",
				default_value   = {},
				keybind_trigger = "pressed",
				keybind_type    = "function_call",
				function_name   = "remove_highlights"
			},
            {
                setting_id  = "collision_group",
                type        = "group",
                sub_widgets = {
                    {
                        setting_id  = "collision_opt_group",
                        type        = "group",
                        sub_widgets = {
                            {
                                setting_id    = "collision_line_number",
                                type          = "numeric",
                                default_value = 5,
                                range         = {1, 25}
                            },
                            {
                                setting_id    = "collision_column_number",
                                type          = "numeric",
                                default_value = 5,
                                range         = {1, 25}
                            },
                            {
                                setting_id    = "collision_line_inter_dist",
                                type          = "numeric",
                                default_value = 100,
                                range         = {1, 200}
                            },
                            {
                                setting_id    = "collision_column_inter_dist",
                                type          = "numeric",
                                default_value = 100,
                                range         = {1, 200}
                            },
                            {
                                setting_id    = "collision_fwd_dist",
                                type          = "numeric",
                                default_value = 30,
                                range         = {1, 100}
                            }
                        }
                    },
                    {
                        setting_id  = "collision_color_group",
                        type        = "group",
                        sub_widgets = {
                            {
                                setting_id    = "collision_alpha",
                                type          = "numeric",
                                default_value = 255,
                                range         = {0, 255}
                            },
                            {
                                setting_id    = "collision_red",
                                type          = "numeric",
                                default_value = 255,
                                range         = {0, 255}
                            },
                            {
                                setting_id    = "collision_green",
                                type          = "numeric",
                                default_value = 255,
                                range         = {0, 255}
                            },
                            {
                                setting_id    = "collision_blue",
                                type          = "numeric",
                                default_value = 255,
                                range         = {0, 255}
                            }
                        }
                    }
                }
            },
            {
                setting_id  = "deathwall_group",
                type        = "group",
                sub_widgets = {
                    {
                        setting_id  = "deathwall_color_group",
                        type        = "group",
                        sub_widgets = {
                            {
                                setting_id    = "deathwall_alpha",
                                type          = "numeric",
                                default_value = 255,
                                range         = {0, 255}
                            },
                            {
                                setting_id    = "deathwall_red",
                                type          = "numeric",
                                default_value = 255,
                                range         = {0, 255}
                            },
                            {
                                setting_id    = "deathwall_green",
                                type          = "numeric",
                                default_value = 0,
                                range         = {0, 255}
                            },
                            {
                                setting_id    = "deathwall_blue",
                                type          = "numeric",
                                default_value = 0,
                                range         = {0, 255}
                            }
                        }
                    }
                }
            }
		}
	}
}