module "taskdef" {
  source = "../taskdef"

  name_prefix     = var.service_name
  container_name  = var.service_name
  container_image = "${var.ecr_repo_url}:${var.service_version}"

  container_cpu                = var.container_cpu
  container_memory             = var.container_memory
  container_memory_reservation = var.container_memory_reservation

  task_role_arn       = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  custom_iam_policies = var.custom_iam_policies

  map_environment = var.environment_variables
  map_secrets     = var.environment_secrets

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

  log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-group" : "koloni-locker-services"
      "awslogs-region" : "us-east-2"
      "awslogs-stream-prefix" : "awslogs-${var.service_name}-{var.environment_name}"
    }
  }
}

module "service" {
  source  = "cn-terraform/ecs-fargate-service/aws"
  version = "2.0.16"

  name_prefix = "${var.environment_prefix}-${var.environment_name}"

  vpc_id          = var.vpc_id
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  # assign_public_ip = true
  security_groups = [var.outbound_sg_id]

  ecs_cluster_arn  = var.cluster_arn
  ecs_cluster_name = var.cluster_name

  task_definition_arn = module.taskdef.task_definition_arn
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
