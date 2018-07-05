import CommandOps from "novacbn/command-ops/CommandOps"

-- ::APPLICATION_SUB_COMMANDS -> table
-- Represents the sub commands accepted by lunarbook
-- export
APPLICATION_SUB_COMMANDS = {
    export: dependency "novacbn/lunarbook/commands/export"
    watch:  dependency "novacbn/lunarbook/commands/watch"
}

commandOps = CommandOps("Lunarbook Documentation Generator", "lunarbook", "0.1.0")

for name, exports in pairs(APPLICATION_SUB_COMMANDS)
    command = commandOps\command(name, exports.TEXT_COMMAND_DESCRIPTION, exports.executeCommand)

    command\setSyntax(exports.TEXT_COMMAND_SYNTAX) if exports.TEXT_COMMAND_SYNTAX
    if exports.TEXT_COMMAND_EXAMPLES
        command\addExample(example) for example in *exports.TEXT_COMMAND_EXAMPLES

    exports.configureCommand(command, command.options) if exports.configureCommand

commandOps\exec([argument for argument in *process.argv[2,]])