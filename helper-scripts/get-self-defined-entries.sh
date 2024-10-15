#! /bin/sh

IDS_FILE='../IDS.TXT'

# Get the lines of the character entries whose first
# composition option is the character itself
selfDefinedChars=$(sed -n "/^[^\t]*\t\(.\)\t^\1/p" "$IDS_FILE")

# Format and show the output
echo "$selfDefinedChars" | sed "s/^\([^\t]*\)\t\(.\).*/\2(\1)/"
