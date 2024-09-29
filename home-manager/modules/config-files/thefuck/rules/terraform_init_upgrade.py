from thefuck.shells import shell
from thefuck.utils import for_app


@for_app('terraform')
def match(command):
    return 'terraform init -upgrade' in command.output
           
def get_new_command(command):
    if 'init' in command.script_parts:
        return 'terraform init -upgrade'
    else:
        return shell.and_('terraform init -upgrade', command.script)

enabled_by_default = True
