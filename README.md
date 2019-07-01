# hubot-azuredevopsplugin
A Hubot plugin that helps users to automate their work-flows.
To use this plugin you should have Hubot, Redis, and 'Azure DevOps Extension for Azure CLI' installed.

----

#### Installation of Hubot:
##### Prerequisites:
1. Slack chat client.
2. Windows machine with PowerShell, latest version of PowerShell is recommended.

##### Insatallation steps:
1. Install Node.js if it isn’t installed. You can find the latest or recommended [here](https://nodejs.org/en/ "Node.js").
2. Create a folder for the bot, you can name it whatever you want, for example: 'myhubot'. This is called as Hubot's home folder.
3. In CMD change the working directory to the new created folder in previous step, then type the following command:
`npm install -g yo generator-hubot` 
As a result all the Hubot required modules will be installed.
4. To initialize Hubot, first make sure you are in Hubot's home folder you created earlier, then execute in CMD the following command:
`yo hubot --adatpter=slack`
It will ask for some initialization data (author's name, bot's name, and optional description). 
Remember the bot's name because you will need it later.
In this stage Hubot files and folders will be generated in the Hubot's home folder; the one we created earlier.
5. Navigate to “Configure Apps” link in your Slack team page, and search for Hubot.
Select “Add Configuration” button; admin approval will be required.
Type the Hubot's name you selected for the “Customize Name” entry then click “Save Integration” button, as a result Hubot will get configured to work with Slack and an API token will be generated for you.
6. Add a new System Environment variable with the following details:
    ```
    Name: “HUBOT_SLACK_TOKEN”
    Value: <Slack API token generated in the previous step>
    ```
7. Open CMD and execute this command:
`set HUBOT_SLACK_TOKEN=<Slack API token generated in the previous step>`
8. To run Hubot on Slack open CMD with administrator privilidges in the Hubot's folder and execute:
`.\bin\hubot --adapter slack`
This will run Hubot on Slack. Stop Hubot by pressing `Ctrl+C` in CMD.

----

#### Installation of Redis:
1. Hubot supports different ways to be used as a brain storage (e.g. File, Redis), for this plugin we will use Redis as Hubot's brain. Redis enables Hubot's memory to be persistent.
2. Download the latest MSI package from [here](https://github.com/microsoftarchive/redis/releases). The MSI package will install Redis as a windows service.
3. Go to Windows services by executing `services.msc` in the run window. Navigate to the 'Extended' tab, and make sure that the Redis service is running.

----

#### Installation of Azure DevOps Extension for Azure CLI:
[This](https://github.com/Azure/azure-devops-cli-extension "Azure DevOps Extension for Azure CLI") link will guide you how to install the Azure DevOps Extension for Azure CLI.

----

#### Installation of hubot-azuredevopsplugin plugin:
1. Open CMD in Hubot's home folder and execute the following command:
`npm install hubot-azuredevopsplugin --save`
This will install the plugin and all the required dependencies.
2. Then add **hubot-azuredevopsplugin** to your `external-scripts.json`, this file is present in Hubot's home folder:
    ```
    [
      "hubot-azuredevopsplugin"
    ]
    ```
3. Open CMD and restart Hubot by executing the following command in Hubot's home folder:
`.\bin\hubot --adapter slack`