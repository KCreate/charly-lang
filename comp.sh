
# Reset the terminal
clear

# Set some needed variables
export CHARLYDIR=./src/charly/std-lib

mkdir -p bin

# Build the interpreter
crystal build src/charly.cr -o bin/charly

RESULT=$?
if [ $RESULT -eq 0 ]; then

  # Execute the interpeter with the given arguments
  time bin/charly $@
fi
