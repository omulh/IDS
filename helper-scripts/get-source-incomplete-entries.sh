#! /bin/sh

IDS_FILE='../IDS.TXT'

# Extract all the compositions in the database.
# Remove comment lines
allCompositions=$(cat "$IDS_FILE" | sed '/^#/d')
# Remove the notes present at the end of some
# entries, i.e., the text after a * character
allCompositions=$(echo "$allCompositions" | sed "s/\t\*.*//")
# Remove the text before the first composition,
# i.e., the entry's character and its unicode number
allCompositions=$(echo "$allCompositions" | sed "s/^[^^]*\t^/^/")
# Arrange to one composition per line
allCompositions=$(echo "$allCompositions" | sed "s/\t/\n/g")
allCompositions=$(echo "$allCompositions" | sed '/^$/d')

# Remove non-compositions, i.e. compositions with only one character
allCompositions=$(echo "$allCompositions" | sed '/^^.\$/d')
# Remove non-CJK characters from the compositions, excepting the source letters
allCompositions=$(echo "$allCompositions" | sed 's/[][0-9{}$^]//g')
allCompositions=$(echo "$allCompositions" | sed 's/[？〾⿰⿻⿱⿲⿳⿴⿵⿶⿷⿸⿹⿺⿿㇯⿾⿼⿽]//g')

# Extract every component used in a composition
# Remove every non-CJK character from the compositions
allComponents=$(echo "$allCompositions" | sed 's/[A-Z()]//g')
# Arrange everything to one character per line
allComponents=$(echo "$allComponents" | sed "s/./&\n/g")
allComponents=$(echo "$allComponents" | sed '/^$/d')
# Remove the duplicates
allComponents=$(echo "$allComponents" | LC_ALL=C sort -u)

#testedLetters='G H M T J K P V U S B Y X Z'
testedLetters='G'
# For every character used as a component
lineCount=$(echo "$allComponents" | wc -l)
processCount=1
while read testedChar; do
    # Output a progress status to the stderr stream
    echo -ne "\r\033[0KProcessing char. $processCount/$lineCount" >&2

    # Check if the char. has its own entry in the database
    charEntry=$(grep -P "\t$testedChar\t" "$IDS_FILE")
    if [[ -n $charEntry ]]; then
        # Get all the letters used in the IDSs for the tested char.
        charEntryLetters=$(echo "$charEntry" | sed 's/[^^]*^//' | sed "s/\t\*.*//")
        charEntryLetters=$(echo "$charEntryLetters" | sed 's/[^A-Z]//g')

        # For every tested letter
        charLetters=''
        error=false
        for testedLetter in $testedLetters; do
            # Check if the char. is used in a composition that has that letter
            if [[ -n $(echo "$allCompositions" | grep -m 1 "$testedChar.*$testedLetter") ]]; then
                charLetters+=$testedLetter
                if [[ $charEntryLetters != *"$testedLetter"* ]]; then
                    error=true
                fi
            fi
        done

        # Output feedback if there was an error
        if [[ $error == true ]]; then
            [ -t 1 ] && echo -en "\r\033[0K"
            echo -n "$testedChar "
            echo -n "is used for: $charLetters "
            echo "and defined for: $charEntryLetters"
        fi
    fi
    ((processCount++))
done < <(echo "$allComponents")
echo -e "\r\033[0KProcessing done" >&2
