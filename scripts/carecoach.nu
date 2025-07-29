export def where-medication-has-cyDu-minusOne [] {
  # For each file, open it, get the Medicaments list, and filter for
  # at least one Pos entry having a "CyDu" field equal to -1.
  each {
    let filename = $in.name
    open $filename |
      get Medicaments |
      where (
        ($it.Pos | where ($it.CyDu? == -1) | length) > 0
      ) |
      if (($in | length) > 0) {
        {
          fileName: $filename,
          medicaments: $in
        }
      }
  }
}

export def where-medication-has-tt-entry [] {
  # For each file, open it, get the Medicaments list, and filter for
  # at least one Pos entry where InRes equals 0 and a TT field exists.
  each {
    let filename = $in.name
    open $filename |
      get Medicaments |
      where (
        ($it.Pos |
           where ($it.InRes == 0 and ($it.TT? | length) > 0) |
           length) > 0
      ) |
      if (($in | length) > 0) {
        {
          fileName: $filename,
          medicaments: $in
        }
      }
  }
}

export def where-patient-has-exitDate-in-PFields [] {
  # For each file, open it and check the Patient.PFields for any entry where
  # the Nm field matches (contains) "exitDate". If a match is found, return an
  # object with the file's name.
  each {
    let filename = $in.name
    open $filename |
      get Patient.PFields |
      where ($it.Nm =~ "exitDate") |
      if (($in | length) > 0) {
        {
          fileName: $filename,
        }
      }
  }
}

export def where-medication-has-multiple-pos [] {
  # For each file, open it, get the Medicaments list, and filter for
  # any medicament that has a Pos array with more than one element.
  each {
    let filename = $in.name
    open $filename |
      get Medicaments |
      where (($it.Pos | length) > 1) |
      if (($in | length) > 0) {
        { fileName: $filename }
      }
  }
}

export def "where Medicaments areNotDeleted" [] {
    where {$in.PFields | any { |pfield| $pfield.Nm == "ccoach.pre.deleted" and $pfield.Val == "0" }}
}

export def "where PFieldAndVal contains" [pfieldSubstring: string, valSubstring: string] {
    where {$in.PFields | any { |pfield| ($pfield.Nm | str contains --ignore-case $pfieldSubstring) and ($pfield.Val | str contains --ignore-case $valSubstring)}}
}

