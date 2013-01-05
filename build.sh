#
# Bash script used to compile source the files
#

echo "Compiling CoffeeScript" &&
/usr/local/share/npm/bin/coffee --compile --output image-picker source/coffee &&
echo "Compiling Sass" &&
sass --scss --update source/sass:image-picker &&
echo "Building examples" &&
/usr/local/share/npm/bin/coffee --compile --output examples/js examples/js &&
sass --scss --update examples:examples &&
echo "Done"