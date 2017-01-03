sudo -v

mkdir -p bin
crystal deps
crystal build src/charly.cr --release --stats -o bin/charly

sudo cp bin/charly /usr/local/bin/charly

echo ""
echo "## IMPORTANT ##"
echo "Don't forget to set \$CHARLYDIR to $(pwd)"
echo "You have to add the following line to ~/.bashrc"
echo ""
echo "export CHARLYDIR="$(pwd)
