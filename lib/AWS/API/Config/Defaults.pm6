unit module AWS::API::Config::Defaults;

my %common =
  access_key_id  => %(
      system        => "AWS_ACCESS_KEY_ID",
      instance_role => False
  ),
  secret_access_key => %(
      system        => "AWS_SECRET_ACCESS_KEY",
      instance_role => False),
  retries => %(
      max_attempts       => 10,
      base_backoff_in_ms => 10,
      max_backoff_in_ms  => 10_000
  );

my %defaults =
    cloudformation => %(
      scheme => "https://",
      host   => -> $region {"cloudformation.$region.amazonaws.com"},
      region => "us-east-1",
      port   => 80
    ),
    kinesis => %(
      scheme => "https://",
      host   => -> $region {"kinesis.$region.amazonaws.com"},
      region => "us-east-1",
      port   => 443
    ),
    firehose => %(
      scheme => "https://",
      host   => -> $region {"firehose.$region.amazonaws.com"},
      region => "us-east-1",
      port   => 443
    ),
    dynamodb => %(
      scheme => "https://",
      host   => -> $region {"dynamodb.$region.amazonaws.com"},
      region => "us-east-1",
      port   => 443
    ),
    dynamodb_streams => %(
      scheme => "https://",
      host   => -> $region {"streams.dynamodb.$region.amazonaws.com"},
      region => "us-east-1",
      port   => 443,
      service_override => :dynamodb
    ),
    elastictranscoder => %(
      scheme => "https://",
      host   => %(
        "us-east-1" => "elastictranscoder.us-east-1.amazonaws.com",
        "us-west-1" => "elastictranscoder.us-west-1.amazonaws.com",
        "us-west-2" => "elastictranscoder.us-west-2.amazonaws.com",
        "ap-south-1" => "elastictranscoder.ap-south-1.amazonaws.com",
        "ap-southeast-1" => "elastictranscoder.ap-southeast-1.amazonaws.com",
        "ap-southeast-2" => "elastictranscoder.ap-southeast-2.amazonaws.com",
        "ap-northeast-1" => "elastictranscoder.ap-northeast-1.amazonaws.com",
        "eu-west-1" => "elastictranscoder.eu-west-1.amazonaws.com",
      ),
      region => "us-east-1"
    ),
    lambda => %(
      host   => -> $region {"lambda.$region.amazonaws.com"},
      scheme => "https://",
      region => "us-east-1",
      port   => 443
    ),
    s3 => %(
      scheme => "https://",
      host   => %(
        "us-east-1" => "s3.amazonaws.com",
        "us-east-2" => "s3-us-east-2.amazonaws.com",
        "us-west-1" => "s3-us-west-1.amazonaws.com",
        "us-west-2" => "s3-us-west-2.amazonaws.com",
        "eu-west-1" => "s3-eu-west-1.amazonaws.com",
        "eu-west-2" => "s3-eu-west-2.amazonaws.com",
        "eu-central-1" => "s3-eu-central-1.amazonaws.com",
        "ap-south-1" => "s3-ap-south-1.amazonaws.com",
        "ap-southeast-1" => "s3-ap-southeast-1.amazonaws.com",
        "ap-southeast-2" => "s3-ap-southeast-2.amazonaws.com",
        "ap-northeast-1" => "s3-ap-northeast-1.amazonaws.com",
        "ap-northeast-2" => "s3-ap-northeast-2.amazonaws.com",
        "sa-east-1" => "s3-sa-east-1.amazonaws.com",
        "ca-central-1" => "s3-ca-central-1.amazonaws.com",
      ),
      region => "us-east-1"
    ),
    sqs => %(
      scheme => "https://",
      host   => -> $region {"sqs.$region.amazonaws.com"},
      region => "us-east-1",
      port   => 443
    ),
    sns => %(
      host   => -> $region {"sns.$region.amazonaws.com"},
      scheme => "https://",
      region => "us-east-1",
      port   => 443
    ),
    ec2 => %(
      scheme => "https://",
      host   => -> $region {"ec2.$region.amazonaws.com"},
      region => "us-east-1",
      port   => 443
    ),
    rds => %(
      scheme => "https://",
      host   => -> $region {"rds.$region.amazonaws.com"},
      region => "us-east-1",
      port   => 443
    ),
    kms => %(
      scheme => "https://",
      host   => -> $region {"kms.$region.amazonaws.com"},
      region => "us-east-1",
      port   => 443
    ),
    sts => %(
      host   => -> $region {"sts.$region.amazonaws.com"},
      scheme => "https://",
      region => "us-east-1",
      port   => 443
    ),
    route53 => %(
      scheme => "https://",
      host   => "route53.amazonaws.com",
      region => "us-east-1",
      port   => 443
    ),
    ses => %(
      scheme => "https://",
      host   => -> $region {"email.$region.amazonaws.com"},
      region => "us-east-1",
      port   => 443
    ),
    monitoring => %(
      host   => -> $region {"monitoring.$region.amazonaws.com"},
      scheme => "https://",
      region => "us-east-1",
      port   => 443
    );

our proto config-defaults(|) is export {*}
our multi config-defaults($service) is export { %(|%defaults{$service}, |%common) }
our multi config-defaults() is export { %() }
