# Create ElasticBeanstalk application
resource "aws_elastic_beanstalk_application" "ebapp" {
  name        = "timeoff-app"
  appversion_lifecycle {
    service_role          = aws_iam_role.ebservicerole.arn #ARN of an IAM service role under which the application version is deleted.
    max_count             = 10 #maximum number of application versions to retain
    delete_source_from_s3 = true #to delete a version's source bundle from S3 when the application version is deleted
  }
  tags = {
    Name = "timeoff-app"
  }
}

# Setup default application
resource "aws_s3_bucket" "default" {
  bucket = "timeoff-jahescobar"
  tags = {
    Name = "timeoff-jahescobar"
  }
}

resource "aws_s3_object" "default" {
  bucket = aws_s3_bucket.default.id
  key    = "beanstalk/nodejs.zip"
  source = "nodejs.zip"
}


resource "aws_elastic_beanstalk_application_version" "default" {
  name        = "tf-default-version"
  application = "timeoff-app"
  description = "application version created by terraform"
  bucket      = aws_s3_bucket.default.id
  key         = aws_s3_object.default.id
}

# Create ElasticBeanstalk Environment
resource "aws_elastic_beanstalk_environment" "ebenv" {
  name                = "timeoff-env"
  application         = aws_elastic_beanstalk_application.ebapp.name
  solution_stack_name = "64bit Amazon Linux 2 v5.6.4 running Node.js 14"
  # To validate running stacks run: aws elasticbeanstalk list-available-solution-stacks|more  
  # oldest nodejs available"64bit Amazon Linux 2 v5.0.2 running Node.js 10"
  #solution_stack_name = "64bit Amazon Linux 2 v3.5.3 running Docker"

# Assing the role to manage instances
  setting {
        namespace = "aws:autoscaling:launchconfiguration"
        name      = "IamInstanceProfile"
        value     = aws_iam_instance_profile.ebec2profile.name
      }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.ebvpc.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",",[aws_subnet.ebsnpub1.id, aws_subnet.ebsnpub2.id])
  }
  setting {
      namespace = "aws:ec2:instances"
      name = "InstanceTypes"
      value = "t4g.micro"
  }

  setting {
      namespace = "aws:ec2:instances"
      name = "SupportedArchitectures"
      value = "arm64"
  }

  setting {
      namespace = "aws:autoscaling:asg"
      name = "MinSize"
      value = 2
  }

  setting {
      namespace = "aws:autoscaling:asg"
      name = "MaxSize"
      value = 4
  }
 
  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "internet facing"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     =  "True"
  }
 
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "MatcherHTTPCode"
    value     = "200"
  
  }
  
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }


  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
  }
  tags = {
    Name = "timeoff-env"
  }
}




