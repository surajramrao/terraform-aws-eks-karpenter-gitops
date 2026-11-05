config {
  call_module_type = "local"
  force            = false
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = false
}
