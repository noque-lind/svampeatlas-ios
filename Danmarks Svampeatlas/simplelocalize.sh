simplelocalize download --apiKey E547A2F9F246106FffcD6869D6D84ad97d3AdFEe0A82D999961d07da2e75E3e4 \
  --downloadFormat localizable-strings \
  --downloadPath ./{lang}.lproj/Localizable.strings \
  --downloadOptions ESCAPE_NEW_LINES

for file in ./*.lproj/Localizable.strings; do
	perl -i -pe "s/%s/%@/g" "$file"
done


