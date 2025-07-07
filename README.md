# Anomalo EventBridge Integrations

This Terraform module provides a set of resources for routing events sent from Anomalo to an AWS EventBridge event bus. It allows you to configure the event source and the event bus ARN.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_anomalo_event_source"></a> [anomalo\_event\_source](#input\_anomalo\_event\_source) | The source of the Anomalo events | `string` | `"com.anomalo.events"` | no |
| <a name="input_event_bus_arn"></a> [event\_bus\_arn](#input\_event\_bus\_arn) | The ARN of the EventBridge event bus | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->