# Declare the region variable for flexibility and clarity.
variable "region" {
    description = "The AWS region to deploy the resources"
    type = string
    default = "ca-central-1" # Default region
}