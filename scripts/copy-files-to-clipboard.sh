#!/bin/bash
# -----------------------------------------------------------------------------
# This script allows you to:
# 1. Use fzf to recursively select a file (fuzzy-find).
# 2. Append the selected file's content to a temporary "clipboard" buffer.
# 3. Display a running list of selected files and an approximate token count
#    (using OpenAI's tiktoken via a Python script for an accurate count)
#    for the accumulated content.
# 4. After each file selection, prompt you for continuing:
#       - Press Enter to select another file.
#       - Press "q" (without Enter) to quit immediately.
#       - Type "exit" (and then Enter) to also quit.
# 5. On quitting, the final token count is shown and the accumulated content
#    is copied to your system clipboard.
#
# Works on macOS (using pbcopy) and Linux (using xclip).
# -----------------------------------------------------------------------------

# Determine the clipboard command based on OS.
if [[ "$OSTYPE" == "darwin"* ]]; then
  CLIP_CMD="pbcopy"
else
  CLIP_CMD="xclip -selection clipboard"
fi

# Create a temporary file for our clipboard buffer.
CLIPBOARD_TMP=$(mktemp)
# Ensure temporary file is empty.
: > "$CLIPBOARD_TMP"

# Array to hold the list of selected files.
declare -a selected_files

# Cleanup temp file on exit.
cleanup() {
  rm -f "$CLIPBOARD_TMP"
  exit
}
trap cleanup EXIT

# Function to count tokens using the tiktoken-based Python script.
approx_tokens() {
  tokens=$(python3 ~/scripts/count_tokens.py < "$CLIPBOARD_TMP")
  echo "$tokens"
}

echo "Instructions:"
echo " - Use fzf to select a file (type part of its name to filter the list)."
echo " - The file's content is appended to a temporary clipboard buffer."
echo " - After each selection, you'll see a list of selected files and an"
echo "   approximate token count for the accumulated content."
echo " - To continue selecting files, simply press Enter."
echo " - To exit immediately and copy the content to the clipboard, press 'q'"
echo "   (without Enter)."
echo " - Alternatively, you may type 'exit' (and press Enter) to finish."
echo

while true; do
  # Use fzf to select a file. 'find' lists all files recursively starting at .
  selected_file=$(find . -type f | fzf --prompt="Select a file (cancel returns empty): " --no-sort)

  # If no file was selected (e.g. by pressing ESC), ask if you want to exit.
  if [ -z "$selected_file" ]; then
    echo ""
    echo "No file selected."
    echo "Press Enter to try again, type 'exit' then Enter to quit, or press the 'q' key now to quit immediately."
    # Read one character silently.
    read -rsn1 key
    if [ "$key" = "q" ]; then
      break
    fi
    # Flush any extra input if the user typed more than one char.
    if [ "$key" != "" ]; then
      read -r rest
      user_choice="$key$rest"
    else
      user_choice=""
    fi
    if [[ "$user_choice" == "exit" ]]; then
      break
    else
      continue
    fi
  fi

  # Append the contents of the selected file to our clipboard buffer.
  if [ -f "$selected_file" ]; then
    cat "$selected_file" >> "$CLIPBOARD_TMP"
    # Add file name to our running list.
    selected_files+=("$selected_file")
  else
    echo "Warning: '$selected_file' is not a regular file. Skipping."
    continue
  fi

  # Display the running list of selected files.
  echo ""
  echo "Files selected so far:"
  for file in "${selected_files[@]}"; do
    echo " - $file"
  done

  # Compute and display token count.
  tokens=$(approx_tokens)
  echo ""
  echo "Approximate token count for accumulated content: $tokens tokens"
  echo ""

  # Prompt to continue or exit.
  echo "Press Enter to select another file, or type 'exit' (and press Enter) to quit."
  echo "You can also press 'q' now (without Enter) to quit immediately."
  # Read one character silently.
  read -rsn1 key
  if [ "$key" = "q" ]; then
    break
  fi
  if [ "$key" != "" ]; then
    read -r rest
    user_choice="$key$rest"
  else
    user_choice=""
  fi
  if [[ "$user_choice" == "exit" ]]; then
    break
  fi
done

# Before copying, print final token count.
final_tokens=$(approx_tokens)
echo ""
echo "Final approximate token count for accumulated content: $final_tokens tokens"

# On exit, copy the accumulated content to the clipboard.
$CLIP_CMD < "$CLIPBOARD_TMP"

echo ""
echo "Accumulated content has been copied to the clipboard."
echo "Exiting script."
