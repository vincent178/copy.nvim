local M = {}

function M.setup()
    vim.api.nvim_create_user_command("CopyAbsoluteFilePath", M.copy_absolute_path, {})
    vim.api.nvim_create_user_command("CopyRelativeFilePath", M.copy_relative_path, {})
    vim.api.nvim_create_user_command("CopyRemoteFileUrl", M.copy_remote_file_url, {})
end

function M.copy_absolute_path()
    vim.fn.setreg("*", vim.fn.expand("%:p"))
end

function M.copy_relative_path()
    vim.fn.setreg("*", vim.fn.expand("%"))
end

local function github_remote_file_url(start_line, end_line)
    local line_number = start_line or vim.fn.line('.')
    local end_line_number = end_line or line_number

    local current_file = vim.fn.expand('%:p')
    local project_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
    local relative_path = vim.fn.fnamemodify(current_file, ':gs?' .. project_root .. '??')

    local repo_url = vim.fn.systemlist("git config --get remote.origin.url")[1]
    local repo_path = vim.fn.substitute(repo_url, '\\(.*github.com\\)\\(:\\|/\\)\\([^/]*\\)/\\(.*\\)\\.git', 'https://github.com/\\3/\\4', '')
    local branch_name = vim.fn.systemlist("git symbolic-ref --short HEAD")[1]
    local base_url = repo_path .. '/blob/' .. branch_name
    local range = 'L' .. line_number
    if line_number ~= end_line_number then
        range = 'L' .. line_number .. '-L' .. end_line_number
    end
    local full_url = base_url .. relative_path .. '#' .. range

    return full_url
end

function M.copy_remote_file_url()
    local start_line, end_line, url

    if vim.fn.line("'<") == 0 and vim.fn.line("'>") == 0 then
        start_line = vim.fn.line('.')
        end_line = start_line
    else
        start_line = vim.fn.line("'<")
        end_line = vim.fn.line("'>")
    end

    if start_line and end_line then
        url = github_remote_file_url(start_line, end_line)
    else
        url = github_remote_file_url()
    end

    vim.fn.setreg("*", url)
end

return M
