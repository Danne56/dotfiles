return {
    entry = function()
        -- Hide Yazi's UI instantly
        permit = ui.hide and ui.hide() or ya.hide()

        -- Spawn lazydocker directly with full TTY inheritance (fastest handoff)
        local child, err_code = Command("lazydocker")
            :stdin(Command.INHERIT)
            :stdout(Command.INHERIT)
            :stderr(Command.PIPED)
            :spawn()

        if child then
            -- Wait for you to exit lazydocker before returning to Yazi
            child:wait()
        else
            -- Failsafe: only triggers if the lazydocker binary is missing from $PATH
            ya.notify({
                title = "lazydocker",
                content = "Failed to launch. Is it installed?\nError: " .. tostring(err_code),
                level = "error",
                timeout = 5,
            })
        end
    end,
}
