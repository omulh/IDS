#! /bin/sh

IDS_FILE='../IDS.TXT'

# Get the lines of the character entries whose first composition
# option is a single character (excepting the fullwidth questionmark)
aliasCharacters=$(sed -n '/^[^\t]*\t.\t^[^？]\$/p' "$IDS_FILE")

# Filter out lines where the composition is the same as the entry's character
aliasCharacters=$(echo "$aliasCharacters" | sed -n '/^[^\t]*\t\(.\)\t^\1/! p')

# Output the character of the filtered lines
echo "$aliasCharacters" | sed "s/^[^\t]*\t//" | sed "s/^\(.\)\t^\(.\).*/\1 -> \2/"
