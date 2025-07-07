provider "aws" {
  region = "us-west-2"
}

module "anomalo_eventbridge" {
  source              = "github.com/joewimmer/terraform-aws-anomalo-eventbridge"
  ip_allow_list       = ["44.230.200.13/32", "104.14.162.108/32"]
}

module "cloudwatch_logs" {
  source        = "./modules/cloudwatch-logs"
  event_bus_arn = module.anomalo_eventbridge.event_bus_arn
}
