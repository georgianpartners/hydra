resource "aws_iam_role" "mlflow_ecs_tasks_role" {
  name                = var.mlflow_ecs_tasks_role
  assume_role_policy  = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role        = aws_iam_role.mlflow_ecs_tasks_role.name
  count       = length(var.ecs_task_iam_policy_arn)
  policy_arn  = var.ecs_task_iam_policy_arn[count.index]
}

resource "aws_security_group" "mlflow_sg" {
  name    = var.mlflow_sg
  vpc_id  = var.vpc_id

  ingress {
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = var.cidr_blocks
  }

  ingress {
    from_port         = 5000
    to_port           = 5000
    protocol          = "tcp"
    cidr_blocks       = var.cidr_blocks
  }

  ingress {
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    self              = true
  }

  egress {
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
    ipv6_cidr_blocks  = ["::/0"]
  }
}