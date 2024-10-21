#! /bin/sh

TESTED_LETTERS="$1"
if [[ -z $TESTED_LETTERS ]]; then
    echo "Aborting, no source letter provided" >&2
    exit
elif [[ -n $(echo "$TESTED_LETTERS" | sed 's/[GHMTJKPVUSB]//g') ]]; then
    echo "Aborting, invalid source letters" >&2
    exit
else
    TESTED_LETTERS=$(echo "$TESTED_LETTERS" | sed 's/./& /g')
fi

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

# Extract every component used in a composition
# Remove every non-CJK character from the compositions
allComponents=$(echo "$allCompositions" | sed 's/[][$^A-Z()]//g')
allComponents=$(echo "$allComponents" | sed 's/[？〾⿰⿻⿱⿲⿳⿴⿵⿶⿷⿸⿹⿺⿿㇯⿾⿼⿽]//g')
# Arrange everything to one character per line
allComponents=$(echo "$allComponents" | sed "s/./&\n/g")
allComponents=$(echo "$allComponents" | sed '/^$/d')
# Remove the duplicates
allComponents=$(echo "$allComponents" | LC_ALL=C sort -u)

# For every unencoded component
for i in $(seq 1 122); do
    # Output a progress status to the stderr stream
    echo -ne "\r\033[0KProcessing unencoded comp. $i/122" >&2

    # Get the char. of the unencoded component
    unencodedChar=$(grep -m 1 -P "#\t\{$i\}" "$IDS_FILE" | sed "s/.*\t//")

    # Check if the char. has its own entry in the database
    charEntry=$(grep -P "\t$unencodedChar\t" "$IDS_FILE")
    if [[ -n $charEntry ]]; then
        # Get all the letters used in the IDSs for the tested component
        charEntryLetters=$(echo "$charEntry" | sed 's/[^^]*^//' | sed "s/\t\*.*//")
        charEntryLetters=$(echo "$charEntryLetters" | sed 's/[^A-Z]//g')

        # For every passed letter
        error=false
        missingLetters=''
        exampleEntries=''
        for testedLetter in $TESTED_LETTERS; do
            # If the char. is used in a composition that has that letter
            compositionWithTestedLetter=$(echo "$allCompositions" | grep -m 1 "{$i}.*$testedLetter")
            if [[ -n $compositionWithTestedLetter ]]; then
                # Check if the letter is absent in the character's entry
                if [[ $charEntryLetters != *"$testedLetter"* ]]; then
                    compositionWithTestedLetter="${compositionWithTestedLetter//$/\\$}"
                    compositionWithTestedLetter="${compositionWithTestedLetter//^/\\^}"
                    compositionEntry=$(grep -m 1 "$compositionWithTestedLetter" "$IDS_FILE")
                    exampleEntries+="\t$testedLetter: $compositionEntry\n"
                    missingLetters+="$testedLetter"
                    error=true
                fi
            fi
        done

        # Output feedback if there was an error
        if [[ $error == true ]]; then
            [ -t 1 ] && echo -en "\r\033[0K"
            echo -e "$unencodedChar is missing:\t$missingLetters"
            echo -e "$exampleEntries"
        fi
    fi
done
echo -e "\r\033[0KProcessing unencoded comps. done" >&2

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

        # For every passed letter
        error=false
        missingLetters=''
        exampleEntries=''
        for testedLetter in $TESTED_LETTERS; do
            # If the char. is used in a composition that has that letter
            compositionWithTestedLetter=$(echo "$allCompositions" | grep -m 1 "$testedChar.*$testedLetter")
            if [[ -n $compositionWithTestedLetter ]]; then
                # Check if the letter is absent in the character's entry
                if [[ $charEntryLetters != *"$testedLetter"* ]]; then
                    compositionWithTestedLetter="${compositionWithTestedLetter//$/\\$}"
                    compositionWithTestedLetter="${compositionWithTestedLetter//^/\\^}"
                    compositionEntry=$(grep -m 1 "$compositionWithTestedLetter" "$IDS_FILE")
                    exampleEntries+="\t$testedLetter: $compositionEntry\n"
                    missingLetters+="$testedLetter"
                    error=true
                fi
            fi
        done

        # Output feedback if there was an error
        if [[ $error == true ]]; then
            [ -t 1 ] && echo -en "\r\033[0K"
            echo -e "$testedChar is missing:\t$missingLetters"
            echo -e "$exampleEntries"
        fi
    fi
    ((processCount++))
done < <(echo "$allComponents")
echo -e "\r\033[0KProcessing chars. done" >&2
