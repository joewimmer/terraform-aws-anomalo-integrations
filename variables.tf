variable "event_bus_arn" {
  description = "The ARN of the EventBridge event bus"
  type        = string
}

variable "anomalo_event_source" {
  description = "The source of the Anomalo events"
  type        = string
  default     = "com.anomalo.events"
}
