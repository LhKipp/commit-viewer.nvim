local M = {}

local log = require('commit-viewer.log')

function M.run_git_cmd(args)
    return M.run_cmd('git', args)
end

function M.run_cmd(cmd, args)
    local Job = require('plenary.job')

    log.debug("Running", cmd, args)

    local proc = Job:new({
        command = cmd,
        args = args,
        cwd = '.',
        enable_recording = true,
    })
    proc:start()
    proc:wait()

    if proc.code ~= 0 then
        vim.api.nvim_err_writeln("Command failure:\n" .. table.concat(proc:stderr_result(), '\n'))
        return nil
    end
    return proc:result()
end

return M
