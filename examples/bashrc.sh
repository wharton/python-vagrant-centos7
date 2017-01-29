# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific aliases and functions
export VIRTUALENV_PYTHON=/usr/local/bin/python3.5
export PATH=/usr/local/bin:/usr/pgsql-9.5/bin:$PATH
source /usr/bin/virtualenvwrapper.sh
source /etc/bash_completion.d/git

# Useful Aliases
alias runserver='python manage.py runserver 0.0.0.0:8000'
alias menu='cat /etc/motd'
alias ccat='pygmentize -O style=monokai -f terminal -g'

# NPM Path
# export PATH=~/npm-global/bin:$PATH
# npm config set prefix '~/npm-global'
