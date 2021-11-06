resource "aws_iam_policy" "CodeDeploy-EC2-S3" {
  name        = "CodeDeploy-EC2-S3"
  description = "AMI Policy for code deploy S3"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:Get*",
                "s3:List*",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:DeleteObjectVersion"
            ],
            "Effect": "Allow",
            "Resource": [ "arn:aws:s3:::${var.S3_BucketName}/*",
                "arn:aws:s3:::${var.s3bucketNameImage}/*"]
        }
    ]
}
EOF
}

resource "aws_iam_policy" "GH-Upload-To-S3" {
  name        = "GH-Upload-To-S3"
  description = "AMI Policy upload to S3"
  policy      = <<EOF
{
 "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:Get*",
                "s3:List*",
                "s3:DeleteObject",
                "s3:DeleteObjectVersion"
            ],
            "Resource": [
                "arn:aws:s3:::${var.S3_BucketName}",
                "arn:aws:s3:::${var.S3_BucketName}/*"
            ]
        }
    ] 
}
EOF
}

resource "aws_iam_policy" "GH-Code-Deploy" {
  name        = "GH-Code-Deploy"
  description = "AMI Policy to call deploy api"
  policy      = <<EOF
{
 "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:RegisterApplicationRevision",
        "codedeploy:GetApplicationRevision"
      ],
      "Resource": [
        "arn:aws:codedeploy:${var.AWS_REGION}:${var.AWS_ACCOUNT_ID}:application:${var.CODE_DEPLOY_APPLICATION_NAME}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:CreateDeployment",
        "codedeploy:GetDeployment"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:GetDeploymentConfig"
      ],
      "Resource": [
        "arn:aws:codedeploy:${var.AWS_REGION}:${var.AWS_ACCOUNT_ID}:deploymentconfig:CodeDeployDefault.OneAtATime",
        "arn:aws:codedeploy:${var.AWS_REGION}:${var.AWS_ACCOUNT_ID}:deploymentconfig:CodeDeployDefault.HalfAtATime",
        "arn:aws:codedeploy:${var.AWS_REGION}:${var.AWS_ACCOUNT_ID}:deploymentconfig:CodeDeployDefault.AllAtOnce"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy" "gh-ec2-ami" {
  name        = "gh-ec2-ami"
  description = "AMI Policy EC2"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CopyImage",
        "ec2:CreateImage",
        "ec2:CreateKeypair",
        "ec2:CreateSecurityGroup",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteKeyPair",
        "ec2:DeleteSecurityGroup",
        "ec2:DeleteSnapshot",
        "ec2:DeleteVolume",
        "ec2:DeregisterImage",
        "ec2:DescribeImageAttribute",
        "ec2:DescribeImages",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeRegions",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSnapshots",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DetachVolume",
        "ec2:GetPasswordData",
        "ec2:ModifyImageAttribute",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifySnapshotAttribute",
        "ec2:RegisterImage",
        "ec2:RunInstances",
        "ec2:StopInstances",
        "ec2:TerminateInstances"
      ],
      "Resource": "*"
    }
  ]
}

EOF
}

resource "aws_iam_role" "CodeDeployServiceRole" {
  name = "CodeDeployServiceRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "CodeDeployEC2ServiceRole" {
  name = "CodeDeployEC2ServiceRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

// data "aws_s3_bucket" "s3bucket" {
//   bucket = var.s3bucketNameImage
// }

// resource "aws_iam_policy" "WebAppS3" {
//   name        = "WebAppS3"
//   description = "IAM Policy"
//   policy      = <<EOF
// {
//   "Version": "2012-10-17",
//   "Statement": [
//     {
//       "Action": [
//                 "s3:ListAllMyBuckets", 
//               "s3:GetBucketLocation",
//               "s3:GetObject",
//               "s3:PutObject",
//               "s3:DeleteObject"
//             ],
//       "Effect": "Allow",
//       "Resource": ["arn:aws:s3:::${data.aws_s3_bucket.s3bucket.id}",
//                 "arn:aws:s3:::${data.aws_s3_bucket.s3bucket.id}/*"]
//     }
//   ]
// }
// EOF
// }


data "aws_iam_user" "appUser" {
  user_name = var.username_iam
}

resource "aws_iam_role_policy_attachment" "CodeDeploy-EC2-S3" {
  role       = aws_iam_role.CodeDeployEC2ServiceRole.name
  policy_arn =  aws_iam_policy.CodeDeploy-EC2-S3.arn
}

# Attach the policy for CodeDeploy role for webapp
resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = "${aws_iam_role.CodeDeployServiceRole.name}"
}

// resource "aws_iam_role_policy_attachment" "GH_Code_Deploy" {
//   role       = aws_iam_role.CodeDeployEC2ServiceRole.name
//   policy_arn =  aws_iam_policy.CodeDeploy-EC2-S3.arn.arn
// }

// resource "aws_iam_role_policy_attachment" "GH_Upload_To_S3" {
//   role       = aws_iam_role.CodeDeployEC2ServiceRole.name
//   policy_arn =  aws_iam_policy.GH-Upload-To-S3.arn
// }

// resource "aws_iam_role_policy_attachment" "WebAppS3-attach" {
//   role       = aws_iam_role.CodeDeployEC2ServiceRole.name
//   policy_arn = aws_iam_policy.WebAppS3.arn
//}
resource "aws_iam_user_policy_attachment" "ec2_ami_policy_attach" {
  user       = data.aws_iam_user.appUser.user_name
  policy_arn = "${aws_iam_policy.gh-ec2-ami.arn}"
}

resource "aws_iam_user_policy_attachment" "GH_Code_policy_attach" {
  user       = data.aws_iam_user.appUser.user_name
  policy_arn = "${aws_iam_policy.GH-Code-Deploy.arn}"
}

resource "aws_iam_user_policy_attachment" "code_upload_policy_attach" {
  user       = data.aws_iam_user.appUser.user_name
  policy_arn = "${aws_iam_policy.GH-Upload-To-S3.arn}"
}
// resource "aws_iam_user_policy_attachment" "code_deploy_policy_attach" {
//   user       = data.aws_iam_user.appUser.user_name
//   policy_arn = "${aws_iam_policy.CodeDeploy-EC2-S3.arn}"
// }
// resource "aws_iam_instance_profile" "iam_ec2_roleprofile" {
//   name = "iam_ec2_roleprofile"
//   role = aws_iam_role.CodeDeployEC2ServiceRole.name
// }

// data "aws_instance" "myinstance" {
  
//   filter {
//     name = "tag:Name"
//     values = ["webapp"]
//   }
// }

// data "aws_route53_zone" "selected" {
//   name         = var.domainName
//   private_zone = false
// }

// resource "aws_route53_record" "www" {
//   zone_id = data.aws_route53_zone.selected.zone_id
//   name    = "api.${data.aws_route53_zone.selected.name}"
//   type    = "A"
//   ttl     = "60"
//   records = ["${data.aws_instance.myinstance.public_ip}"]
// }


// resource "aws_iam_user_policy_attachment" "app-attach-s3" {
//   user       = data.aws_iam_user.appUser.user_name
//   policy_arn =  aws_iam_policy.GH-Upload-To-S3.arn
// }

// resource "aws_iam_user_policy_attachment" "app-attach-deploy" {
//   user       = data.aws_iam_user.appUser.user_name
//   policy_arn =  aws_iam_policy.GH-Code-Deploy.arn
// }

// resource "aws_iam_user_policy_attachment" "app-attach-ec2-ami" {
//   user       = data.aws_iam_user.appUser.user_name
//   policy_arn =  aws_iam_policy.gh-ec2-ami.arn
// }