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
  echo # Add a newline for cleaner exit messages
  rm -f "$CLIPBOARD_TMP"
  # No explicit exit here, let the script finish naturally or handle errors
}
# Use EXIT trap for normal exit and errors, INT/TERM for interruptions
trap cleanup EXIT INT TERM

# Function to count tokens using the tiktoken-based Python script.
approx_tokens() {
  # Check if the script exists and is executable
  local token_script=~/scripts/count_tokens.py
  if [[ ! -x "$token_script" ]]; then
    echo "Error: Token counting script '$token_script' not found or not executable." >&2
    echo "0" # Return 0 tokens on error
    return 1
  fi
  # Check if python3 is available
  if ! command -v python3 &> /dev/null; then
     echo "Error: python3 command not found. Cannot count tokens." >&2
     echo "0" # Return 0 tokens on error
     return 1
  fi
  # Check if the temp file exists before reading
  if [[ ! -f "$CLIPBOARD_TMP" ]]; then
      echo "Error: Temporary clipboard file not found." >&2
      echo "0"
      return 1
  fi
  tokens=$(python3 "$token_script" < "$CLIPBOARD_TMP")
  # Handle potential errors from the python script
  if [[ $? -ne 0 ]] || ! [[ "$tokens" =~ ^[0-9]+$ ]]; then
      echo "Error running token counting script or invalid output." >&2
      echo "0"
      return 1
  fi
  echo "$tokens"
}

echo "Instructions:"
echo " - Use fzf to select a file (type part of its *filename* to filter)."
echo " - The file's content is appended to a temporary clipboard buffer."
echo " - After each selection, you'll see a list of selected files and an"
echo "   approximate token count for the accumulated content."
echo " - To continue selecting files, simply press Enter."
echo " - To exit immediately and copy the content to the clipboard, press 'q'"
echo "   (without Enter)."
echo " - Alternatively, you may type 'exit' (and press Enter) to finish."
echo

while true; do
  # Use fd to find files, awk to format "filename<TAB>fullpath"
  # Use fzf to select based on filename (nth 1), delimited by tab
  # --type f ensures we only get files
  # awk -F/ '{print $NF "\t" $0}' extracts filename ($NF) and prints it with the full path ($0)
  selected_line=$(fd --type f --absolute-path . | awk -F/ '{print $NF "\t" $0}' | \
    fzf --prompt="Select file (match filename): " \
        --no-sort \
        --delimiter='\t' \
        --nth=1 \
        --preview 'bat --color=always --style=numbers --line-range 5:60 {2}' \
        --preview-window=right:50%:wrap \
        --bind 'ctrl-/:toggle-preview')

  # If no file was selected (e.g. by pressing ESC), fzf returns empty string.
  if [ -z "$selected_line" ]; then
    echo ""
    echo "No file selected."
    echo "Press Enter to try again, type 'exit' then Enter to quit, or press the 'q' key now to quit immediately."
    # Read one character silently.
    read -rsn1 key
    if [ "$key" = "q" ]; then
      break
    fi
    # Flush any extra input if the user typed more than one char.
    local user_choice="" # Use local for loop variables
    if [ "$key" != "" ]; then
      # Read rest of line with timeout to avoid blocking if user just hit Enter
      read -r -t 0.1 rest
      user_choice="$key$rest"
    fi
    if [[ "$user_choice" == "exit" ]]; then
      break
    else
      continue # Go back to the fzf prompt
    fi
  fi

  # Extract the full path (the second field) from the selected line
  # Use printf/cut for robustness with potential special characters vs echo
  selected_file=$(printf "%s" "$selected_line" | cut -f2- -d$'\t')

  # Double check if cut produced a result (it should if selected_line wasn't empty)
   if [ -z "$selected_file" ]; then
      echo "Warning: Could not extract file path from selection: '$selected_line'. Skipping." >&2
      continue
   fi

  # Append the contents of the selected file to our clipboard buffer.
  if [ -f "$selected_file" ]; then
    # Add error handling for cat
    if cat "$selected_file" >> "$CLIPBOARD_TMP"; then
      # Add file name to our running list.
      selected_files+=("$selected_file")
    else
      echo "Error: Failed to read file '$selected_file'. Skipping." >&2
      # Optionally remove the failed file from the list if it was added prematurely
      # Or handle the partial append if necessary
      continue
    fi
  else
    echo "Warning: '$selected_file' is not a regular file or not found. Skipping." >&2
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
  # Check if token counting failed (returned non-zero status)
  if [[ $? -ne 0 ]]; then
      echo "Token count unavailable due to previous errors."
  else
      echo ""
      echo "Approximate token count for accumulated content: $tokens tokens"
  fi
  echo ""

  # Prompt to continue or exit.
  echo "Press Enter to select another file, or type 'exit' (and press Enter) to quit."
  echo "You can also press 'q' now (without Enter) to quit immediately."
  # Read one character silently.
  read -rsn1 key
  if [ "$key" = "q" ]; then
    break
  fi
  local user_choice="" # Use local
  if [ "$key" != "" ]; then
    # Read rest of line with timeout
    read -r -t 0.1 rest
    user_choice="$key$rest"
  fi
  if [[ "$user_choice" == "exit" ]]; then
    break
  fi
  # If user just pressed Enter (key is empty), the loop continues automatically
done

# Before copying, print final token count.
final_tokens=$(approx_tokens)
if [[ $? -ne 0 ]]; then
    echo "Final token count unavailable due to errors."
else
    echo ""
    echo "Final approximate token count for accumulated content: $final_tokens tokens"
fi

# On exit, copy the accumulated content to the clipboard if the temp file exists and has content.
if [ -s "$CLIPBOARD_TMP" ]; then # Check if file exists and is not empty
  if $CLIP_CMD < "$CLIPBOARD_TMP"; then
    echo ""
    echo "Accumulated content has been copied to the clipboard."
  else
    echo "Error: Failed to copy content to clipboard using '$CLIP_CMD'." >&2
  fi
else
  echo ""
  echo "No content was accumulated to copy."
fi

echo "Exiting script."

# The cleanup function will run automatically via the trap