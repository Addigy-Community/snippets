# Iterate through users and perform some tasks.
# Variables and functions that need to be accesible in subshells must be exported (duh).
# Enclose arguments in single-quotes to preserve bash internal variables, etc.
# Example Usage:
# userIteration 'remove "$HOME/Library/Containers/com.microsoft.Excel"'

userIteration() {
    for ITERATED_USER in $(dscl . list /Users UniqueID | awk '$2 >= 500 {print $1}'); do
        su $ITERATED_USER -c "$*"
    done
}
