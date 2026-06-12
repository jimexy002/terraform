module "s3_bucket" {
  source = ""

  buckett = var.buckett
  #left side is the variable name defined in the module, right side is the variable defined in variables.tf file of this module locally, you can use this file to override the default variable values defined in variables.tf. This allows you to customize the configuration without modifying the main.tf or variables.tf files directly.
  acl    = var.acl

  control_object_ownership = var.control_object_ownership
  object_ownership         = var.object_ownership

  versioning = {
    enabled = var.versioning["enabled"]
  }
}