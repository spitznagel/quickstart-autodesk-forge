aws cloudformation --region us-west-2 create-stack --stack-name Forge-Prod-Stack \
  --template-url https://aws-cfn-samples.s3.amazonaws.com/quickstart-autodesk-forge/templates/autodesk-forge-master.json \
  --parameters file://forge-prod-cfn.json \
  --capabilities "CAPABILITY_IAM" --disable-rollback
