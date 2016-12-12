
# Reset the terminal
clear

mkdir -p bin

# Build the interpreter
crystal build src/charly.cr -o bin/charly

RESULT=$?
if [ $RESULT -eq 0 ]; then

  # Execute the interpeter with the given arguments
  time bin/charly $@
fi
