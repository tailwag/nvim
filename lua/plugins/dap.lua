return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
            "theHamsta/nvim-dap-virtual-text",
        },
        config = function()
            local function get_pio_envs()
                local envs = {}
                local ini_path = vim.fn.getcwd() .. "/platformio.ini"

                if vim.fn.filereadable(ini_path) == 0 then
                    return envs
                end

                for line in io.lines(ini_path) do
                    local env = line:match("%[env:(.+)%]")
                    if env then
                        table.insert(envs, env)
                    end
                end

                return envs
            end

            local function pick_pio_env(callback)
                local envs = get_pio_envs()

                if #envs == 0 then
                    vim.notify("No PlatformIO environments found in platformio.ini", vim.log.levels.ERROR)
                    return
                end

                -- If there's only one, no need to ask
                if #envs == 1 then
                    callback(envs[0])
                    return
                end

                vim.ui.select(envs, {
                    prompt = "Select PlatformIO Environment:",
                }, function(choice)
                    callback(choice)
                end)
            end

            local function auto_pio_elf(callback)
                pick_pio_env(function(env)
                    local path = string.format("%s/.pio/build/%s/firmware.elf",
                        vim.fn.getcwd(), env)
                    callback(path)
                end)
            end

            local dap = require "dap"
            local dapui = require "dapui"

            require("dapui").setup()
            require("nvim-dap-virtual-text").setup()

            dap.adapters.gdb = {
                type = "executable",
                command = "gdb",
                args = { "--interpreter=dap", "--eval-command", "set pretty print on" },
            }

            dap.adapters.arm = {
                type = 'executable',
                command = 'arm-none-eabi-gdb',
                args = { '-i=dap' }
            }

            dap.configurations.cpp = {
                {
                    name = "Launch",
                    type = "gdb",
                    request = "launch",
                    program = function()
                      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                    end,
                    args = {}, -- provide arguments if needed
                    cwd = "${workspaceFolder}",
                    stopAtBeginningOfMainSubprogram = false,
                },
                {
                    name = "Select and attach to process",
                    type = "gdb",
                    request = "attach",
                    program = function()
                      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                    end,
                    pid = function()
                      local name = vim.fn.input('Executable name (filter): ')
                      return require("dap.utils").pick_process({ filter = name })
                    end,
                    cwd = '${workspaceFolder}'
                },
                {
                    name = 'Attach to gdbserver :1234',
                    type = 'gdb',
                    request = 'attach',
                    target = 'localhost:1234',
                    program = function()
                      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                    end,
                    cwd = '${workspaceFolder}'
                },
                {
                    name = "ST-Link w/ Remote GDB",
                    type = "arm",
                    request = "launch",
                    program = function()
                        local boardId = vim.fn.input('Board ID: ')
                        return '${workspaceFolder}/.pio/build/' .. boardId .. '/firmware.elf'
                    end,
                    cwd = '${workspaceFolder}',
                    stopAtEntry = true,
                    gdb_cmd = 'arm-none-eabi-gdb',
                    postRunCommands = {
                        'target extended-remote 127.0.0.1:3333'
                    }
                },
            }
            -- VSCode-like keymaps
            vim.keymap.set("n", "<Leader>duo", function() dapui.open() end)
            vim.keymap.set("n", "<Leader>duc", function() dapui.close() end)
            vim.keymap.set("n", "<F5>", function() dap.continue() end)
            vim.keymap.set("n", "<F10>", function() dap.step_over() end)
            vim.keymap.set("n", "<F11>", function() dap.step_into() end)
            vim.keymap.set("n", "<F12>", function() dap.step_out() end)
            vim.keymap.set("n", "<Leader>b", function() dap.toggle_breakpoint() end)
            vim.keymap.set("n", "<Leader>B", function()
                dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
            end)

            dap.listeners.before.attach.dapui_config = function()
                dapui.open()
            end

            dap.listeners.before.launch.dapui_config = function()
                dapui.open()
            end

            dap.listeners.before.event_terminated.dapui_config = function()
                dapui.close()
            end

            dap.listeners.before.event_exited.dapui_config = function()
                dapui.close()
            end
        end,
    },
}

