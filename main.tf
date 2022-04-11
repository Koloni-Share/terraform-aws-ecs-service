locals {
  container_image = "${var.ecr_repo_url}:${var.service_version}"
}

module "container_definition" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.53.0"

  container_name               = var.service_name
  container_image              = local.container_image
  container_memory             = var.container_memory
  container_memory_reservation = var.container_memory_reservation
  container_definition         = {}

  port_mappings = [
    {
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    },
    {
      containerPort = 443
      hostPort      = 443
      protocol      = "tcp"
    }
  ]

  healthcheck              = var.healthcheck
  container_cpu            = var.container_cpu
  essential                = var.essential
  entrypoint               = var.entrypoint
  command                  = var.command
  working_directory        = var.working_directory
  environment              = var.environment_variable_list
  extra_hosts              = var.extra_hosts
  map_environment          = var.environment_variables
  environment_files        = var.environment_files
  map_secrets              = var.environment_secrets
  readonly_root_filesystem = var.readonly_root_filesystem
  linux_parameters         = var.linux_parameters

  log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-group" : "koloni-locker-services"
      "awslogs-region" : "us-east-2"
      "awslogs-stream-prefix" : "awslogs-${var.service_name}-{var.environment_name}"
    }
  }

  firelens_configuration  = var.firelens_configuration
  mount_points            = var.mount_points
  dns_servers             = var.dns_servers
  dns_search_domains      = var.dns_search_domains
  ulimits                 = var.ulimits
  repository_credentials  = var.repository_credentials
  volumes_from            = var.volumes_from
  links                   = var.links
  user                    = var.user
  container_depends_on    = var.container_depends_on
  docker_labels           = var.docker_labels
  start_timeout           = var.start_timeout
  stop_timeout            = var.stop_timeout
  privileged              = var.privileged
  system_controls         = var.system_controls
  hostname                = var.hostname
  disable_networking      = var.disable_networking
  interactive             = var.interactive
  pseudo_terminal         = var.pseudo_terminal
  docker_security_options = var.docker_security_options
}

# Task Definition
resource "aws_ecs_task_definition" "td" {
  family                = "${var.service_name}-td"
  container_definitions = "[${module.container_definition.json_map_encoded}]"
  task_role_arn         = aws_iam_role.ecs_instance_role.arn
  execution_role_arn    = aws_iam_role.ecs_task_execution_role.arn
  network_mode          = "awsvpc"
  dynamic "placement_constraints" {
    for_each = var.placement_constraints
    content {
      expression = lookup(placement_constraints.value, "expression", null)
      type       = placement_constraints.value.type
    }
  }
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  requires_compatibilities = ["FARGATE"]
  dynamic "proxy_configuration" {
    for_each = var.proxy_configuration
    content {
      container_name = proxy_configuration.value.container_name
      properties     = lookup(proxy_configuration.value, "properties", null)
      type           = lookup(proxy_configuration.value, "type", null)
    }
  }
  dynamic "volume" {
    for_each = var.volumes
    content {
      name = volume.value.name

      host_path = lookup(volume.value, "host_path", null)

      dynamic "docker_volume_configuration" {
        for_each = lookup(volume.value, "docker_volume_configuration", [])
        content {
          autoprovision = lookup(docker_volume_configuration.value, "autoprovision", null)
          driver        = lookup(docker_volume_configuration.value, "driver", null)
          driver_opts   = lookup(docker_volume_configuration.value, "driver_opts", null)
          labels        = lookup(docker_volume_configuration.value, "labels", null)
          scope         = lookup(docker_volume_configuration.value, "scope", null)
        }
      }

      dynamic "efs_volume_configuration" {
        for_each = lookup(volume.value, "efs_volume_configuration", [])
        content {
          file_system_id          = lookup(efs_volume_configuration.value, "file_system_id", null)
          root_directory          = lookup(efs_volume_configuration.value, "root_directory", null)
          transit_encryption      = lookup(efs_volume_configuration.value, "transit_encryption", null)
          transit_encryption_port = lookup(efs_volume_configuration.value, "transit_encryption_port", null)
          dynamic "authorization_config" {
            for_each = lookup(efs_volume_configuration.value, "authorization_config", [])
            content {
              access_point_id = lookup(authorization_config.value, "access_point_id", null)
              iam             = lookup(authorization_config.value, "iam", null)
            }
          }
        }
      }
    }
  }

  tags = var.tags
}


module "service" {
  source  = "cn-terraform/ecs-fargate-service/aws"
  version = "2.0.16"

  name_prefix = var.name_prefix

  vpc_id          = var.vpc_id
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  # assign_public_ip = true
  security_groups = [var.outbound_sg_id]

  ecs_cluster_arn  = var.cluster_arn
  ecs_cluster_name = var.cluster_name

  task_definition_arn = aws_ecs_task_definition.td.arn
  container_name      = var.service_name

  default_certificate_arn = var.certificate_arn

  lb_ip_address_type = var.lb_ip_address_type
  lb_https_ports = {
    "container_listener" : {
      "listener_port" : 443,
      "target_group_port" : 80,
      "target_group_protocol" : "HTTP",
      "type" : "forward"
    }
  }
  lb_http_ports = {
  }

  lb_internal                       = var.lb_internal
  lb_target_group_health_check_path = var.health_check_path
}
