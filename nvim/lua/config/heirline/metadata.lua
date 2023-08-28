local conditions = require("heirline.conditions")
local utils = require("heirline.utils")
local vim = vim

local CocStatus = {
    condition = function()
        return pcall(function() vim.fn["coc#status"]() end)
    end,
    update = function(self) 
        return self.status ~= vim.fn["coc#status"]()
    end,
    --{ "User", pattern = { "CocDiagnosticChange", "CocStatusChange" }, callback = vim.schedule_wrap(function() vim.cmd("redrawstatus") end), },
    init = function(self)
        self.status = vim.fn["coc#status"]()
    end,
    provider = function()
        return vim.fn["coc#status"]()
    end,
}


local Diagnostics = {
    condition = conditions.has_diagnostics,
    static = {
        error_icon = "!", -- vim.fn.sign_getdefined("DiagnosticSignError")[1].text,
        warn_icon = "!",  --, vim.fn.sign_getdefined("DiagnosticSignWarn")[1].text,
        info_icon = "i",  --vim.fn.sign_getdefined("DiagnosticSignInfo")[1].text,
        hint_icon = "h",  --vim.fn.sign_getdefined("DiagnosticSignHint")[1].text,
    },
    init = function(self)
        self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
        self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
        self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
        self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    end,
    update = { "DiagnosticChanged", "BufEnter" },
    {
        provider = "![",
    },
    {
        provider = function(self)
            -- 0 is just another output, we can decide to print it or not!
            return self.errors > 0 and (self.error_icon .. self.errors .. " ")
        end,
        hl = { fg = "diag_error" },
    },
    {
        provider = function(self)
            return self.warnings > 0 and (self.warn_icon .. self.warnings .. " ")
        end,
        hl = { fg = "diag_warn" },
    },
    {
        provider = function(self)
            return self.info > 0 and (self.info_icon .. self.info .. " ")
        end,
        hl = { fg = "diag_info" },
    },
    {
        provider = function(self)
            return self.hints > 0 and (self.hint_icon .. self.hints)
        end,
        hl = { fg = "diag_hint" },
    },
    {
        provider = "]",
    },
}

local Git = {
    condition = conditions.is_git_repo,
    init = function(self)
        self.status_dict = vim.b.gitsigns_status_dict
        self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
    end,
    hl = { fg = "orange" },
    {
        -- git branch name
        provider = function(self)
            return " " .. self.status_dict.head
        end,
        hl = { bold = true }
    },
    -- You could handle delimiters, icons and counts similar to Diagnostics
    {
        condition = function(self)
            return self.has_changes
        end,
        provider = "("
    },
    {
        provider = function(self)
            local count = self.status_dict.added or 0
            return count > 0 and ("+" .. count)
        end,
        --hl = { fg = "git_add" },
    },
    {
        provider = function(self)
            local count = self.status_dict.removed or 0
            return count > 0 and ("-" .. count)
        end,
        --hl = { fg = "git_del" },
    },
    {
        provider = function(self)
            local count = self.status_dict.changed or 0
            return count > 0 and ("~" .. count)
        end,
        --hl = { fg = "git_change" },
    },
    {
        condition = function(self)
            return self.has_changes
        end,
        provider = ")",
    },
}


return { diagnostic = Diagnostics, git = Git, cocstatus = CocStatus }
