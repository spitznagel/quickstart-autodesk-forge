EMAIL=
FORGE_CLIENT_ID=
FORGE_CLIENT_SECRET=
IP_ADDRESS="10.0.0.1\/24"

# DO NOT MODIFY BELOW THIS LINE
KEY_PAIR=forge-demo
CODE_HOSTING_BUCKET=$(cat code-bucket.txt)

files="taskcat_project_override.json forge-prod-cfn.json forge-prod-codepipeline.json"

echo "Updating input parameter files"
for f in $files; do
    sed -i "s/YOUR_EMAIL/$EMAIL/g" $f
    sed -i "s/YOUR_KEY_PAIR/$KEY_PAIR/g" $f
    sed -i "s/YOUR_FORGE_CLIENT_ID/$FORGE_CLIENT_ID/g" $f
    sed -i "s/YOUR_FORGE_CLIENT_SECRET/$FORGE_CLIENT_SECRET/g" $f
    sed -i "s/YOUR_CODE_HOSTING_BUCKET/$CODE_HOSTING_BUCKET/g" $f
    sed -i "s/YOUR_IP_ADDRESS/$IP_ADDRESS/g" $f  
done    

echo "Updating CodePipeline configuration zip file"
PROD_CONFIG=forge-prod-codepipeline.json

ZIP_FILE=quickstart-autodesk-forge.zip
if test -f "$ZIP_FILE"; then
    rm -v $ZIP_FILE
fi

cp quickstart-autodesk-forge/templates/autodesk-forge-master.json .
zip $ZIP_FILE autodesk-forge-master.json ${PROD_CONFIG}
rm autodesk-forge-master.json
