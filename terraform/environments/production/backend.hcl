# terraform init -backend-config=backend.hcl
bucket         = "8byte-tfstate-yaswanth"
dynamodb_table = "terraform-state-lock"
