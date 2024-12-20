terraform {
  backend "s3" {
    bucket         = ""                                 // replace with your configured backend s3 bucket 
    key            = "blog/terraform.tfstate"          // replace with unique name
    region         = "ap-south-1"

    dynamodb_table = ""                               // Replace this with your DynamoDB table name!
    encrypt        = true
  }
}
