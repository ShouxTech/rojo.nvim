local rojoServePid;

local Rojo = {};

local function runRojoCommand(command)
    local cmd = {'rojo', unpack(vim.split(command, ' ', {trimempty = true}))};

    vim.system(cmd, {text = true}, function(obj)
        vim.schedule(function()
            if obj.stdout and #obj.stdout > 0 then
                vim.api.nvim_echo({{obj.stdout}}, true, {});
            end;

            if obj.stderr and #obj.stderr > 0 then
                vim.api.nvim_err_write(obj.stderr);
            end;

            if obj.code ~= 0 then
                vim.api.nvim_err_write('Rojo command failed with exit code: ' .. obj.code .. '\n');
            end;
        end);
    end);
end;

local function startRojoServe()
    local cmd = {'rojo', 'serve', '--color', 'never'}; -- Use '--color never' option to disable unnecessary color formatting in output.

    rojoServePid = vim.fn.jobstart(cmd, {
        on_stdout = function(_, data)
            if not data then return; end;
            vim.api.nvim_echo({{table.concat(data, '\n')}}, true, {});
        end,
        on_stderr = function(_, data)
            if not data then return; end;
            vim.api.nvim_err_write(table.concat(data, '\n') .. '\n');
        end,
        on_exit = function(_, code)
            -- Note: Might want to check exit code at some point.
            rojoServePid = nil;
        end,
    });
end;

local function stopRojoServe()
    if rojoServePid then
        vim.fn.jobstop(rojoServePid);
        rojoServePid = nil;
        vim.api.nvim_out_write('Rojo serve process stopped.\n');
    else
        vim.api.nvim_err_write('Rojo serve is not running.\n');
    end;
end;

function Rojo.setup()
    -- For plugin development/testing purposes.
    -- vim.api.nvim_create_user_command('Rojo', function(opts)
    --     runRojoCommand(opts.args);
    -- end, {
    --     nargs = '*',
    --     desc = 'Run a Rojo CLI command directly',
    -- });

    vim.api.nvim_create_user_command('RojoVersion', function()
        runRojoCommand('--version');
    end, {desc = 'View the current version of Rojo installed'});

    vim.api.nvim_create_user_command('RojoServe', function()
        if rojoServePid then vim.api.nvim_err_write('Rojo serve is already running.\n'); return; end;
        startRojoServe();
    end, {desc = 'Serve with Rojo in the current directory'});

    vim.api.nvim_create_user_command('RojoServeStop', function()
        stopRojoServe();
    end, {desc = 'Stop serving Rojo in the current directory'});

    vim.api.nvim_create_user_command('RojoInit', function()
        runRojoCommand('init');
    end, {desc = 'Initialize a new Rojo project in the current directory'});

    vim.api.nvim_create_autocmd('VimLeavePre', {
        callback = function()
            if not rojoServePid then return; end;
            stopRojoServe();
        end,
    });
end;

return Rojo;
