local M = {}

function M.setup(opts)
    -- Set the default values for the options
    local defaults = {
        default_remote = "origin",
    }

    -- Merge the user-provided options with the defaults
    local options = vim.tbl_extend("keep", opts or {}, defaults)

    -- Set the global variables to the user-provided options
    vim.g.nvim_github_linker_default_remote = options.default_remote
end

function M.copy_absolute_path()
    vim.fn.setreg("*", vim.fn.expand("%:p"))
end

function M.copy_relative_path()
    vim.fn.setreg("*", vim.fn.expand("%"))
end

function M.remote_file_url(start_line, end_line)
    local line_number = start_line or vim.fn.line('.')
    local end_line_number = end_line or line_number

    local current_file = vim.fn.expand('%:p')
    local project_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
    local relative_path = vim.fn.fnamemodify(current_file, ':gs?' .. project_root .. '??')

    local repo_url = vim.fn.systemlist("git config --get remote." .. vim.g.nvim_github_linker_default_remote .. ".url")[
        1]
    local repo_path = vim.fn.substitute(repo_url, '\\(.*github.com\\)\\(:\\|/\\)\\([^/]*\\)/\\(.*\\)\\.git',
        'https://github.com/\\3/\\4', '')
    local branch_name = vim.fn.systemlist("git symbolic-ref --short HEAD")[1]
    local base_url = repo_path .. '/blob/' .. branch_name
    local range = 'L' .. line_number
    if line_number ~= end_line_number then
        range = 'L' .. line_number .. '-L' .. end_line_number
    end
    local full_url = base_url .. relative_path .. '#' .. range

    return full_url
end

function M.github_linker_command()
    local start_line, end_line, url

    -- Check if a range is provided
    if vim.fn.line("'<") == 0 and vim.fn.line("'>") == 0 then
        start_line = vim.fn.line('.')
        end_line = start_line
    else
        -- If no range is provided, use the current line
        start_line = vim.fn.line("'<")
        end_line = vim.fn.line("'>")
    end

    -- save to clipboard
    if start_line and end_line then
        url = M.github_linker(start_line, end_line)
    else
        url = M.github_linker()
    end

    if vim.g.nvim_github_linker_copy_to_clipboard then
        vim.fn.setreg("*", url)
    else
        print(url)
    end
end

return M