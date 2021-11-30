if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi

# Add SSH keys to agent (macOS Sierra)
ssh-add -A 2>/dev/null

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
