output "task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "task_execution_role_create_date" {
  value = aws_iam_role.ecs_task_execution_role.create_date
}

output "task_execution_role_description" {
  description = "The description of the role"
  value       = aws_iam_role.ecs_task_execution_role.description
}

output "task_execution_role_id" {
  description = "The ID of the role"
  value       = aws_iam_role.ecs_task_execution_role.id
}

output "task_execution_role_name" {
  description = "the name of the role"
  value       = aws_iam_role.ecs_task_execution_role.name
}

output "task_execution_role_unique_id" {
  description = "the stable and unique string identifying the role"
  value       = aws_iam_role.ecs_task_execution_role.unique_id
}

output "task_definition_arn" {
  description = "full ARN of the task definition (including both family and revision)"
  value       = aws_ecs_task_definition.td.arn
}

output "task_definition_family" {
  value = aws_ecs_task_definition.td.family
}

output "task_definition_revision" {
  value = aws_ecs_task_definition.td.revision
}

output "container_name" {
  value = var.container_name
}
