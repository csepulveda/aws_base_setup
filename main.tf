terraform {
  backend "remote" {
    organization = "csepulveda_io"

    workspaces {
      name = "AWSBaseSetup"
    }
  }
}
