# ~/workspaces/dotfiles/scripts/find_missing_codes.nu
def main [
    json_file_path_str: string,     # Receive JSON file path as a raw string
    other_list_to_check_str: string # Receive the list as a raw string
] {
    print $"DEBUG: Received json_file_path_str: ($json_file_path_str)";
    print $"DEBUG: Received other_list_to_check_str: ($other_list_to_check_str)";

    # Attempt to parse the list string explicitly
    let other_list_to_check = ($other_list_to_check_str | from json | each { |it| $"($it)" }); # Ensure strings after parsing

    print $"DEBUG: Parsed other_list_to_check type: ($other_list_to_check | describe)";
    print $"DEBUG: Parsed other_list_to_check length: ($other_list_to_check | length)";

    # --- Original logic using the (now explicitly parsed) variables ---
    let json_file_path = $json_file_path_str; # Use the original variable name for consistency

    let codes_from_json = (
        open $json_file_path
        | get entry
        | where resource.resourceType? == "MedicationStatement"
        | where resource.effectivePeriod?.end? == null
        | get resource.contained?.code?.coding?
        | compact
        | flatten
        | flatten
        | where system? == "urn:oid:2.16.756.5.30.2.6.3"
        | get code?
        | compact
        | uniq
        | each { |it| $"($it)" } # Ensure all are strings
    )
    
    print $"DEBUG: Parsed codes_from_json type: ($codes_from_json | describe)";
    print $"DEBUG: Parsed codes_from_json length: ($codes_from_json | length)";

    let missing_codes = (
        $codes_from_json | where { |code_to_check|
            $code_to_check not-in $other_list_to_check
        }
    )

    $missing_codes
}