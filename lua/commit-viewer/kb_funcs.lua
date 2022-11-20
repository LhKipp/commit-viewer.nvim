local M = {}

local log = require 'commit-viewer.log'
local vim = vim

local t = function(s) return vim.api.nvim_replace_termcodes(s, true, true, true) end

local sha_regex = [[^[^0-9]*[0-9]\{4}-[0-9]\{2}-[0-9]\{2}\s\+\zs[a-f0-9]\+]]
M.sha = function(line)
    line = line or "."
    return vim.fn.matchstr(vim.fn.getline(line), sha_regex)
end

local desc_regex = [[^[^0-9]*[0-9]\{4}-[0-9]\{2}-[0-9]\{2}\s\+[a-f0-9]\+\s\+\zs.*]]
M.commit_desc = function(max_len, line)
    line = line or "."
    local desc = vim.fn.matchstr(vim.fn.getline(line), desc_regex)
    return string.sub(desc, 0, max_len)
end

M.kb_exe = function(cmd, args)
    return function()
        log.debug("kb_exe", cmd, vim.inspect(args))

        local mapped_args = {}
        for _, arg in ipairs(args) do
            arg = string.gsub(arg, "<sha>", M.sha())
            table.insert(mapped_args, arg)
        end
        local result = require 'commit-viewer.util'.run_cmd(cmd, mapped_args)
        if result == nil then
            return
        end
        print(table.concat(result, "\n"))
        require 'commit-viewer'.redraw()
    end
end

M.kb_feedkeys = function(format_string)
    return function()
        log.debug("kb_feekdeys ", format_string)

        local cmd = string.gsub(format_string, [[<sha>]], M.sha())
        local _, endi = string.find(cmd, [[<cursor>]])
        if endi ~= nil then
            local shifts = ""
            for _ = endi + 1, string.len(cmd) do
                shifts = shifts .. [[<left>]]
            end
            cmd = string.gsub(cmd, [[<cursor>]], "")
            cmd = cmd .. shifts
        end
        vim.api.nvim_feedkeys(t(cmd), 'n', false)
    end
end

M.kb_open_commit = function(options)
    local get_window = function()
        if options.new_tab ~= nil and options.new_tab == true then
            vim.cmd(":tabnew<CR>")
        end
        if options.window_layout == "horizontal" then
            vim.cmd.split()
        elseif options.window_layout == "vertical" then
            vim.cmd.vsplit()
        end
        if options.window_resize ~= nil then
            vim.cmd.resize(options.window_resize)
        end
        return vim.api.nvim_get_current_win()
    end

    local exe_cmd = function(args)
        local util = require 'commit-viewer.util'
        local result = util.run_git_cmd(args)
        if result == nil then
            return
        end
        local win = get_window()

        local buf = vim.api.nvim_create_buf(false, true)
        if buf == 0 then
            vim.api.nvim_err_writeln("Couldn't create a new buffer!")
            return nil
        end
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, result)
        vim.api.nvim_win_set_buf(win, buf)
        vim.api.nvim_buf_set_option(buf, 'filetype', 'git')
    end

    local open_single_commit = function()
        local args = { "show", M.sha() }
        exe_cmd(args)
    end

    return function()
        if string.find(vim.fn.mode(), "^V") ~= nil then
            local a = vim.fn.getpos("v")[2]
            local b = vim.fn.getpos(".")[2]
            if (a > b) then
                a, b = b, a
            end

            if a == b then
                open_single_commit()
            end

            local from = M.sha(b)
            local to = M.sha(a)
            local args = { "diff", string.format("%s..%s", from, to) }
            exe_cmd(args)
        else
            open_single_commit()
        end
    end
end

return M
