CONFIG_REGION=us-west-2
SUFFIX=$(uuidgen | cut -c'1-13')
CONFIG_BUCKET_NAME=au-demo-config-$SUFFIX
echo $CONFIG_BUCKET_NAME > config-bucket.txt
aws s3 mb s3://${CONFIG_BUCKET_NAME} --region ${CONFIG_REGION}
aws s3api put-public-access-block --bucket ${CONFIG_BUCKET_NAME} --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
aws s3api put-bucket-versioning --bucket ${CONFIG_BUCKET_NAME}  --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket ${CONFIG_BUCKET_NAME} --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'

echo "Created config bucket: $CONFIG_BUCKET_NAME"

CODE_HOSTING_REGION=us-east-1
CODE_BUCKET_NAME=au-demo-code-$SUFFIX
echo $CODE_BUCKET_NAME > code-bucket.txt
aws s3 mb s3://${CODE_BUCKET_NAME} --region ${CODE_HOSTING_REGION}
aws s3api put-public-access-block --bucket ${CODE_BUCKET_NAME} --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
aws s3api put-bucket-encryption --bucket ${CODE_BUCKET_NAME} --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'

echo "Created code hosting bucket: $CODE_BUCKET_NAME"

# Delete forge-demo key pair if exists
aws ec2 delete-key-pair --region us-west-2 --key-name forge-demo
aws ec2 delete-key-pair --region us-west-1 --key-name forge-demo

aws ec2 create-key-pair --region us-west-2 --key-name forge-demo --output text > forge-demo-us-west-2.pem
aws ec2 create-key-pair --region us-west-1 --key-name forge-demo --output text > forge-demo-us-west-1.pem 
echo "Created forge-demo key pair in us-west-1 and us-west-2"