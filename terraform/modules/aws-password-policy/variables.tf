variable "aws_account_password_policy" {
  type = any
  default = {
    minimum_password_length        = 14    # Minimum length to require for user passwords
    password_reuse_prevention      = 10    # The number of previous passwords that users are prevented from reusing
    require_lowercase_characters   = true  # If true, password must contain at least 1 lowercase symbol
    require_numbers                = true  # If true, password must contain at least 1 number symbol
    require_uppercase_characters   = true  # If true, password must contain at least 1 uppercase symbol
    require_symbols                = true  # If true, password must contain at least 1 special symbol
    allow_users_to_change_password = true  # Whether to allow users to change their own password
    max_password_age               = 90    # How many days user's password is valid
    hard_expiry                    = false # Don't allow users to set a new password after their password has expired
  }
}
