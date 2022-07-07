[
    {
      "name": "${container_name}",
      "image": "${container_image}",
      "cpu": ${container_cpu},
      "memory": ${container_memory},
      "memoryReservation": ${container_memory},
      "secrets": [
      {
        "name": "database_username",
        "valueFrom": "${database_username_secretsmanager_secret_arn}"
      },
      {
        "name": "database_password",
        "valueFrom": "${database_password_secretsmanager_secret_arn}"
      }
      ],
      "entryPoint": [
          "/bin/sh",
          "-c"
      ],
      "command": [],
      "environment": [
        { "name" : "database_name", "value" : "${database_name}" }
      ],
      "healthCheck": {
        "retries": 5,
        "command": [
          "CMD-SHELL",
          "curl -f http://localhost:8080 || exit 1"
        ],
        "timeout": 5,
        "interval": 30,
        "startPeriod": 120
      },
      "essential": true,
      "mountPoints": [],
      "portMappings": [
        {
          "containerPort": ${web_ui_port}
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${awslogs_group}",
            "awslogs-region": "${region}",
            "awslogs-datetime-format": "%Y-%m-%d",
            "awslogs-stream-prefix": "${awslog_stream_prefix}"
        }
      }
    }
]