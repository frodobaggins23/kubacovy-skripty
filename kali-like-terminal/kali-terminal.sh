#!/bin/bash

highlight_echo() {
    local color=$1
    local message=$2

    case $color in
        red)
            echo -e "\e[1;31m$message\e[0m"
            ;;
        green)
            echo -e "\e[1;32m$message\e[0m"
            ;;
        yellow)
            echo -e "\e[1;33m$message\e[0m"
            ;;
        *)
            echo "$message"
            ;;
    esac
}

perform_step() {
    local step_description=$1
    local command=$2

    highlight_echo green "Step: $step_description"
    echo "[default] Copy command to clipboard"
    echo "[s] Skip step"
    echo "[q] Exit script"
    read -p "Choose an option: " choice

    case $choice in
        s)
            highlight_echo red "Step skipped."
            ;;
        q)
            highlight_echo red "Exiting script."
            exit 0
            ;;
        *)
            if command -v xclip &> /dev/null; then
                echo -n "$command" | xclip -selection clipboard
                echo "Command copied to clipboard."
            else
                highlight_echo red "xclip is not installed. Please install xclip to use this feature."
                exit 1
            fi
            ;;
    esac
}

# Example steps
perform_step "Installing zsh" "sudo apt-get install zsh"
perform_step "Change default shell to zsh" "chsh -s \$(which zsh)"
perform_step "Install zsh extensions" "apt install zsh-autosuggestions zsh-syntax-highlighting"
perform_step "Copy zsh configuration" "cp .zshrc-template ~/.zshrc"

highlight_echo yellow "Script completed successfully."
echo "Please restart the terminal"
