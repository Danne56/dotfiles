local get_cwd = ya.sync(function()
    return tostring(cx.active.current.cwd)
end)

return {
    entry = function(self, job)
        local action = job.args and job.args[1]

        if not action then
            ya.notify({ title = "Error", content = "No action provided.", timeout = 3.0 })
            return
        end

        local cwd = get_cwd()

        -- Initialize the command builder
        local cmd = Command("docker"):cwd(cwd)

        -- Append arguments individually using the supported arg() method
        cmd:arg("compose")
        cmd:arg(action)

        if action == "up" then
            cmd:arg("-d")
        end

        -- Execute and capture output streams
        local output, err = cmd:stdout(Command.PIPED)
            :stderr(Command.PIPED)
            :output()

        if not output then
            ya.notify({ title = "Execution Failed", content = tostring(err), timeout = 4.0 })
            return
        end

        local result = output.stderr
        if result == "" then
            result = output.stdout
        end

        if result == "" then
            result = "Success: Exit code " .. tostring(output.status.code)
        end

        ya.notify({
            title = "Docker Compose " .. action,
            content = result,
            timeout = 5.0
        })
    end
}
