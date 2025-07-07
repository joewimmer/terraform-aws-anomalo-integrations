provider "aws" {
  region = "us-west-2"
}

module "anomalo_eventbridge" {
  source = "github.com/joewimmer/terraform-aws-anomalo-eventbridge"
}

module "cloudwatch_logs" {
  source        = "./modules/cloudwatch-logs"
  event_bus_arn = module.anomalo_eventbridge.event_bus_arn
}
