return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
            "theHamsta/nvim-dap-virtual-text",
        },
        config = function()
            local dap = require "dap"
            local dapui = require "dapui"

            require("dapui").setup()
            require("nvim-dap-virtual-text").setup()

            dap.adapters.cppdbg = {
                id = 'cppdbg',
                type = 'executable',
                command = '/home/island/.local/share/nvim/mason/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7',
            }
            dap.adapters.gdb = {
                type = "executable",
                command = "gdb",
                args = { "--interpreter=dap", "--eval-command", "set pretty print on" },
            }
            -- dap.configurations.cpp = {
            --     {
            --         name = "Launch File",
            --         type = "cppdbg",
            --         request = "launch",
            --         program = function()
            --             return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. '/', 'file')
            --         end,
            --         cwd = '${workspaceFolder}',
            --         stopAtEntry = true;
            --     },
            --     {
            --         name = 'Attach to gdbserver :1234',
            --         type = 'cppdbg',
            --         request = 'launch',
            --         MIMode = 'gdb',
            --         miDebuggerServerAddress = 'localhost:1234',
            --         miDebuggerPath = '/usr/bin/gdb',
            --         cwd = '${workspaceFolder}',
            --         program = function()
            --             return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
            --         end,
            --     },
            -- }
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
                }
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

