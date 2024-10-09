#! /bin/sh

IDS_FILE='../IDS.TXT'

# Get the lines of the character entries whose first
# composition option is the character itself
selfDefinedChars=$(sed -n "/^[^\t]*\t\(.\)\t^\1/p" "$IDS_FILE")

# Remove the text before and after the entry's
# character for the remaining lines and output
echo "$selfDefinedChars" | sed "s/^[^\t]*\t//" | sed -r "s/^(.).*/\1/"
