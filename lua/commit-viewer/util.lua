local M = {}

function M.run_git_cmd(args)
    local Job = require('plenary.job')

    local proc = Job:new({
        command = 'git',
        args = args,
        cwd = '.',
        enable_recording = true,
    })
    proc:start()
    proc:wait()

    if proc.code ~= 0 then
        vim.api.nvim_err_writeln("Git command failure:\n" .. table.concat(proc:stderr_result(), '\n'))
        return nil
    end
    return proc:result()
end

return M

