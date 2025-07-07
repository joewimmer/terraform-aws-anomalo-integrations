variable "prefix" {
  description = "The prefix to use for all resources"
  type        = string
  default     = "Anomalo-Events-Cloudwatch"
}

variable "event_bus_arn" {
  description = "The ARN of the EventBridge event bus"
  type        = string
}

variable "anomalo_event_source" {
  description = "The source of the Anomalo events"
  type        = string
  default     = "com.anomalo.events"
}

variable "anomalo_cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group for Anomalo events"
  type        = string
  default     = "/anomalo/events/check-runs"
  
}