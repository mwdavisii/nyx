hl.monitor({ output = "", mode = "highres", position = "auto", scale = 1 })
hl.monitor({ output = "desc:Dell Inc. Dell AW3821DW", mode = "3840x1600@144S", position = "0x1440", scale = 1 })
hl.monitor({ output = "desc:Dell Inc. AW2725DM", mode = "2560x1440@144", position = "1920x0", scale = 1 })

-- prometheus desk: pin workspaces by monitor model (no-op when those monitors aren't attached)
hl.workspace_rule({ workspace = "1", monitor = "desc:Dell Inc. Dell AW3821DW", default = true })
hl.workspace_rule({ workspace = "2", monitor = "desc:Dell Inc. AW2725DM", default = true })
hl.workspace_rule({ workspace = "3", monitor = "desc:Dell Inc. AW2725DM" })
