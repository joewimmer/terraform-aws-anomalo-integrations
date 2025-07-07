provider "aws" {
  region = "us-west-2"
}


module "cloudwatch_logs" {
  source        = "./modules/cloudwatch-logs"
  event_bus_arn = "arn:aws:events:us-west-2:1234567890:event-bus/anomalo"
}
