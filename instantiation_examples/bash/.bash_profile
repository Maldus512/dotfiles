#
# ~/.bash_profile
#
#
export npm_config_prefix=~/.node_modules

#export LD_LIBRARY_PATH=$HOME/Local/JLink:$LD_LIBRARY_PATH
export EDITOR=nvim

export HISTCONTROL="ignoreboth"
export HISTSIZE=-1

# Espressif path
export LIBOPENCM3="/home/maldus/Source/libopencm3"

export PATH="/snap/bin:$PATH"
export PATH="$HOME/Local/bin:$PATH"
export PATH="$HOME/Mount/Data/Flatpak/exports/bin:$PATH"
export PATH="$PATH:$HOME/Mount/Data/Local/flutter/bin"
export PATH="$PATH:/opt/android-sdk/tools/bin"
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
export ANDROID_HOME="$HOME/Mount/Data/Android"
export ANDROID_AVD_HOME="$HOME/Mount/Data/Android/avd"
export FVM_CACHE_PATH="$HOME/Mount/Data/Local/flutter/"

export PYTHONPATH="$HOME/Local/python/local/lib/python3.11/dist-packages"

export PATH="$PATH:/home/maldus/.ghcup/bin"
export PATH="$PATH:/home/maldus/.cargo/bin"
export PATH="$PATH:/home/maldus/.local/bin"
export PATH="$PATH:/home/maldus/.node_modules/bin"
export PATH="$PATH:/home/maldus/Local/python/local/bin"

export WINEPREFIX="/home/maldus/Mount/Data/Wine"
export ACCESSIBILITY_ENABLED=1

HISTIGNORE='ecryptfs*'
export PROMPT_COMMAND='history -a'
export FZF_DEFAULT_COMMAND='{ find . -xdev ; find Mount; }' 
export BARTIB_FILE="$HOME/Mount/Data/Documents/activities.bartib"

export QT_XCB_GL_INTEGRATION=xcb_egl

[[ -f ~/.bashrc ]] && . ~/.bashrc
[[ -f ~/.system_theme_env.sh ]] && . ~/.system_theme_env.sh
. "$HOME/.cargo/env"

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[ -f /home/maldus/.dart-cli-completion/bash-config.bash ] && . /home/maldus/.dart-cli-completion/bash-config.bash || true
## [/Completion]


SSH_ENV="$HOME/.ssh/agent-environment"

function start_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' >"$SSH_ENV"
    echo succeeded
    chmod 600 "$SSH_ENV"
    . "$SSH_ENV" >/dev/null
    /usr/bin/ssh-add;
}

# Source SSH settings, if applicable

if [ -f "$SSH_ENV" ]; then
    . "$SSH_ENV" >/dev/null
    #ps $SSH_AGENT_PID doesn't work under Cygwin
    ps -ef | grep $SSH_AGENT_PID | grep ssh-agent$ >/dev/null || {
        start_agent
    }
else
    start_agent
fi
