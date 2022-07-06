## Adding somain identity
resource "aws_ses_domain_identity" "this" {
  domain = var.domain_name
}

## Adding email identity
resource "aws_ses_email_identity" "email" {
  count = length(var.email)
  email = var.email[count.index]
}
