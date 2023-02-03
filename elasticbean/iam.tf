resource "aws_iam_instance_profile" "ebserviceprofile" {
  name = "ebserviceprofile"
  role = aws_iam_role.ebservicerole.name
}
resource "aws_iam_instance_profile" "ebec2profile" {
  name = "ebec2profile"
  role = aws_iam_role.ebec2role.name
}
resource "aws_iam_role" "ebservicerole" {
  name = "ebservicerole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticbeanstalk.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "elasticbeanstalk"
        }
      }
    }
  ]
}
EOF
}
resource "aws_iam_role" "ebec2role" {
  name = "ebec2role"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_policy_attachment" "ebservicepa" {
  name = "ebservicepa"
  roles = [aws_iam_role.ebservicerole.id]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}
resource "aws_iam_policy_attachment" "ebservicehealthpa" {
  name = "ebservicehealthpa"
  roles = [aws_iam_role.ebservicerole.id]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}
resource "aws_iam_policy_attachment" "ebec2webpa" {
  name = "ebec2webpa"
  roles = [aws_iam_role.ebec2role.id]
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}
