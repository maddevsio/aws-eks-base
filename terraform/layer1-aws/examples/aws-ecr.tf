resource "aws_ecr_repository" "main" {
  count = length(var.ecr_repos)
  name  = format("${local.name}/%s", var.ecr_repos[count.index])

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "main" {
  count      = length(var.ecr_repos)
  repository = aws_ecr_repository.main.*.name[count.index]
  policy     = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images more than ${var.ecr_repo_retention_count} count",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": ${var.ecr_repo_retention_count}
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF

  depends_on = [aws_ecr_repository.main]
}

output "docker_repository_urls" {
  value       = aws_ecr_repository.main.*.repository_url
  description = "description"
}
