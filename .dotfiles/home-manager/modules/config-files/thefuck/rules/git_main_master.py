from thefuck.utils import replace_argument

@git_support
def match(command):
    return ('fatal: invalid reference: master' in command.output or
            'fatal: invalid reference: main' in command.output)

@git_support
def get_new_command(command):
    if 'master' in command.output:
        return replace_argument(command.script, 'master', 'main')
    elif 'main' in command.output:
        return replace_argument(command.script, 'main', 'master')
    else:
        return ''
