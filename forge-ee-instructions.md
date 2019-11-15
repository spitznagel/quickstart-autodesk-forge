# Setup

1. Fork the following GitHub repository in your account: [https://github.com/vsnyc/quickstart-autodesk-forge/](https://github.com/vsnyc/quickstart-autodesk-forge/)

2. Go to AWS console using the **AWS Console** link in your Event Engine dashboard.

3. In the Services, search for Cloud9 and go to Cloud9 console. You will find a Cloud9 IDE pre-provisioned with the name that starts with `forge-workshop-`. Choose **Open IDE**.

4. Create [GitHub token](http://workshop.quickstart.awspartner.com/10_prerequisites/30_github_token.html).

5. In Cloud9 IDE, open a new Terminal window and configure git, substituting your GitHub user name and email inside the quotes in the following commands:

    ```
    cd ~/environment
    git config --global user.name "YOUR_GITHUB_USERNAME" 
    git config --global user.email "YOUR_GITHUB_EMAIL"
    git config --global credential.helper cache
    git config --global credential.helper 'cache --timeout=3600'
    ```

6. Clone git repo in Cloud9 IDE, replacing `YOUR_GITHUB_USERNAME` with your GitHub user name:

    ```
    git clone --recursive https://github.com/YOUR_GITHUB_USERNAME/quickstart-autodesk-forge.git
    ```

7. Download workshop assets. This will be located at the Root level of the project together with the quickstart-autodesk-forge folder.

    ```
    cd ~/environment
    curl -O https://aws-cfn-samples.s3.amazonaws.com/forge-workshop/forge-workshop-assets.zip
    ```

8. Unzip workshop assets  

    `unzip forge-workshop-assets.zip`

9. Let's run the following command to make buckets and key pairs. We create two buckets: `config bucket` to host test and 
production configuration parameters; and the `hosting bucket` to host the Quick Start code; i.e., 
CloudFormation templates and scripts. We also create a `forge-demo` key pair in `US West (Oregon)` and `US West (N. California)` Regions.

    `bash make_buckets_key_pairs.sh`

    Sample output (you will get different values for the ID's):

    ```
    make_bucket: au-demo-config-5ac3c715-5857
    Created config bucket: au-demo-config-5ac3c715-5857
    make_bucket: au-demo-code-5ac3c715-5857
    Created code hosting bucket: au-demo-code-5ac3c715-5857
    Created forge-demo key pair in us-west-1 and us-west-2
    ```

10. The names of the created buckets are saved to file system for future reference. We'll need them again in [Section 3](#setting-up-continuous-deployment), Step 3. Export the config bucket to an environment variable for convenience  

    `export CONFIG_BUCKET=$(cat config-bucket.txt)`

11. Open update_artifacts.sh and fill lines 1-4 as follows. Be sure to not add any spaces after the properties: `EMAIL`, `FORGE_CLIENT_ID`, etc.
   
    Property | Value
    ---------|------
    EMAIL    | Any valid email address that you own. This will be used to send EC2 Auto Scaling and CodePipeline action notifications
    FORGE_CLIENT_ID  | The Forge client ID of your pre-existing Forge application
    FORGE_CLIENT_SECRET | The Forge client secret of your pre-existing Forge application
    IP_ADDRESS | You can either update it with your IP address (check at http://checkip.amazonaws.com/, e.g. "1.2.3.4\\/32") or with "0.0.0.0\\/0" to allow access from anywhere. Note the backslash for IP address value, it is required to escape it during substitution.
   
12. Now let's execute the following command to use the updated input values and generate a zip file containing configuration needed for our CodePipeline that we'll be creating in a few minutes.

    `bash update_artifacts.sh`

13. Let's verify the substituted tokens in `forge-prod-cfn.json`, `forge-prod-codepipeline.json`, and `taskcat_project_override.json`.

# Deploy the Quick Start with default app
14. Deploy the Quick Start with the default Forge application by running the command below. This will create a new CloudFormation stack in your account with the name: `Forge-Prod-Stack`.

    `bash run_cfn.sh`
    
15. This step will take approximately 15 minutes, we'll come back and verify that our base application has deployed correctly. To test your application, go to the CloudFormation console and choose the `Forge-Prod-Stack`. In the Outputs section, go to the link provided as the value of `ForgeAppURL`.
    
# Setting up continuous deployment
   
16. We will now update our app and setup a CodePipeline to deploy our changes automatically. We'll replace the default app with a app that contains the dashboard. In the Cloud9 IDE:
    1. In terminal, go to the repo directory: `cd quickstart-autodesk-forge`
    2. Checkout develop branch: `git checkout develop`
    3. open `quickstart-autodesk-forge/templates/autodesk-forge-nodejs.json`. Change `FORGE_APP_NAME` in line 147 to `forge-viewmodels-nodejs-aws-dashboard`. Save the file.
    4. open `quickstart-autodesk-forge/templates/autodesk-forge.json`. Change `Toggle` value in line 801 from "false" to "true". Save the file.
    5. In terminal, from the quickstart-autodesk-forge directory, add the files, commit and push. When asked for a password, use your GitHub personal access token created in Step 4.
           
          ```
            git add -A
            git commit -m "Updated app to include a dashboard"
            git push
          ```

17. Let's upload the `quickstart-autodesk-forge.zip` and the test config file  `taskcat_project_override.json` to config bucket  
    ```
    cd ~/environment
    aws s3 cp quickstart-autodesk-forge.zip s3://$CONFIG_BUCKET/
    aws s3 cp taskcat_project_override.json s3://$CONFIG_BUCKET/
    ```
18. In a new browser tab, open the following [launch stack link](https://us-west-2.console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/create/review?stackName=Forge-App-CICD&templateURL=https://aws-cfn-samples.s3.amazonaws.com/quickstart-taskcat-ci/templates/taskcat-cicd-pipeline.template.yaml&param_ProdStackName=Forge-Prod-Stack&param_ProdStackConfig=forge-prod-codepipeline.json&param_TemplateFileName=autodesk-forge-master.json&param_TestStackConfig=taskcat_project_override.json&param_SourceRepoBranch=develop&param_ReleaseBranch=master&param_QSS3KeyPrefix=quickstart-taskcat-ci/&param_QSS3BucketName=aws-cfn-samples&param_GitHubRepoName=quickstart-autodesk-forge&param_KeepTestStack=True) that will setup your CodePipeline. Most fields are populated with defaults, fill in only the blank fields.

    * Repository owner: your GitHub user name
    * OAuth2 token: your GitHub oauth token created in Step 4
    * Email: your email address
    * ConfigBucket: your config bucket created in Step 9, this value is saved in `config-bucket.txt`
    * CodeHostingBucket: your code hosting bucket created in Step 9, this value is saved in `code-bucket.txt`

19. Select both the check boxes in the Capabilities section and choose **Create Stack**. After the `Forge-App-CICD` stack is created, it will automatically execute the CodePipeline. 

20. It takes about 25 minutes for the pipeline to reach the PROD stage. In AWS CodePipeline console, go to the pipeline service and manually approve the last step in the PROD Stage. 

21. After that, you should see `Forge-Prod-Stack` being updated. Once the update is complete, go to the `ForgeAppURL` again and verify that your application now shows a dashboard for your models. (Tested in Chrome browser)



