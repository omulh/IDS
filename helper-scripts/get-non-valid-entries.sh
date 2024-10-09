#! /bin/sh

IDS_FILE='../IDS.TXT'

# Remove comment lines
allCompositions=$(cat "$IDS_FILE" | sed '/^#/d')
# Remove the notes present at the end of some
# entries, i.e., the text after a * character
allCompositions=$(echo "$allCompositions" | sed "s/\t\*.*//")
# Remove the text before the entry's character,
# i.e., the entry's character unicode number
allCompositions=$(echo "$allCompositions" | sed "s/^[^\t]*\t//")

# Remove composition options with mirror, variation, rotation or
# subtraction IDCs, i.e., compositions with any of ⿾〾⿿㇯ in them
while [[ -n $(echo "$allCompositions" | sed -n "/\t[^\t]*[⿾〾⿿㇯][^\t]*\t/p") ]]; do
    allCompositions=$(echo "$allCompositions" | sed "s/\t[^\t]*[⿾〾⿿㇯][^\t]*\t/\t/")
done
allCompositions=$(echo "$allCompositions" | sed "s/\t[^\t]*[⿾〾⿿㇯][^\t]*$//")

# Remove composition options with unrepresentable components,
# i.e. compositions with ？(fullwidth question mark) in them
while [[ -n $(echo "$allCompositions" | sed -n "/\t[^\t]*？[^\t]*\t/p") ]]; do
    allCompositions=$(echo "$allCompositions" | sed "s/\t[^\t]*？[^\t]*\t/\t/")
done
allCompositions=$(echo "$allCompositions" | sed "s/\t[^\t]*？[^\t]*$//")

# Output the characters that are left with
# no composition options after the removal
echo "$allCompositions" | grep "^.$"
