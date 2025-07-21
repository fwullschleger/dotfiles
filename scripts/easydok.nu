export def find-medicationStatements [] {
  get entry
  | where { |entry_item|
      let res = $entry_item.resource;
      # only keep MedicationStatement resources
      $res.resourceType? == "MedicationStatement"
  }
  | get resource
}

export def find-medicationStatement-by-productCode [productCode: string] {
  get entry
  | where { |entry_item|
      let res = $entry_item.resource;
      #if ($res.resourceType? == "MedicationStatement") and ($res.effectivePeriod?.end? == null) {
      if ($res.resourceType? == "MedicationStatement") {
          $res.contained? | default [] | any { |cont_res|
              $cont_res.code?.coding? | default [] | any { |coding_table|
                  ($coding_table.system? == "urn:oid:2.16.756.5.30.2.6.3") and ($coding_table.code? == $productCode)
              }
          }
      } else {
          false
      }
  }
  | get resource
}

export def medicationStatements.print-medication-info [] {
   select contained.code.coding.0.display.0 dosage.text dosage.timing dosage.doseAndRate.0.doseQuantity
}

export def medicationStatements.whereNameContains [nameSubstring: string] {
    where {$in.contained.code.coding | flatten | get display | any {str contains --ignore-case $nameSubstring}}
}