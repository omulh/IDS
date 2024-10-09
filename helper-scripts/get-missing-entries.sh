#! /bin/sh

IDS_FILE='../IDS.TXT'

# Extract all the CJK characters that are used in
# compositions for entries of the IDS database.
# Remove comment lines
allComponents=$(cat "$IDS_FILE" | sed '/^#/d')
# Remove the notes present at the end of some
# entries, i.e., the text after a * character
allComponents=$(echo "$allComponents" | sed "s/\t\*.*//")
# Remove the text before the first ^ character,
# i.e., the entry's character and its unicode number
allComponents=$(echo "$allComponents" | sed "s/^[^^]*\t^//")
# Remove every non-CJK character from the compositions
allComponents=$(echo "$allComponents" | sed 's/[0-9A-Z]//g')
allComponents=$(echo "$allComponents" | sed "s/[][\t$^(){}]//g")
allComponents=$(echo "$allComponents" | sed 's/[？〾⿰⿻⿱⿲⿳⿴⿵⿶⿷⿸⿹⿺⿿㇯⿾⿼⿽]//g')
# Arrange everything to one character per line
allComponents=$(echo "$allComponents" | sed "s/./&\n/g")
allComponents=$(echo "$allComponents" | sed '/^$/d')
# Remove the duplicates
allComponents=$(echo "$allComponents" | LC_ALL=C sort -u)

# Check if the extracted characters have
# their own entry in the IDS database
lineCount=$(echo "$allComponents" | wc -l)
processCount=1
while read testedChar; do
    # Output a progress status to the stderr stream
    echo -ne "\r\033[0KProcessing char. $processCount/$lineCount" >&2
    # Output the characters that do not have their own entriy
    if ! grep -q -P "\t$testedChar\t" "$IDS_FILE"; then
        [ -t 1 ] && echo -en "\r\033[0K"
        echo "$testedChar"
    fi
    ((processCount++))
done < <(echo "$allComponents")
echo -e "\r\033[0KProcessing done" >&2
