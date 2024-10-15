#! /bin/sh

IDS_FILE='../IDS.TXT'

# Get the lines of the character entries whose first composition
# option is a single character (excepting the fullwidth questionmark)
aliasCharacters=$(sed -n '/^[^\t]*\t.\t^[^？]\$/p' "$IDS_FILE")

# Filter out lines where the composition is the same as the entry's character
aliasCharacters=$(echo "$aliasCharacters" | sed -n '/^[^\t]*\t\(.\)\t^\1/! p')

# Format and show the output
while read line; do
    aliasedCharAndNum=$(echo "$line" | sed 's/^\([^\t]*\)\t\(.\).*/\2(\1)/')
    aliasChar=$(echo "$line" | sed 's/^[^\t]*\t.\t^//' | sed 's/\(.\).*/\1/')
    aliasUnicodeNum=$(grep -P "\t$aliasChar\t" "$IDS_FILE" | sed 's/^\([^\t]*\)\t.*/\1/')
    echo "$aliasedCharAndNum -> $aliasChar($aliasUnicodeNum)"
done < <(echo "$aliasCharacters")
