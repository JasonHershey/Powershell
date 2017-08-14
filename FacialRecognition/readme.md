# Azure Cognitive Services Facial Recognition API test

This script is a short example/test of the Azure cognitive services facial recogntion apis.  You can find more details about these apis 
at [Face API Documentation](https://docs.microsoft.com/en-us/azure/cognitive-services/face/).

My purpose in creating the script is to make sure I understand how the APIs work.  Im a big fan of PowerShell and I find it a great place
to prototype code, since I have a high level of confidence I know what I'm doing here.  This is similar to the [Voice Recognition](https://github.com/JasonHershey/Powershell/tree/master/VoiceRecognition) sample I created

Beyond the standard prerequisites for running scripts, this example assumes the following:
1. You have an Azure Subscription and you added a Cognitive Services Facial Recognition API subscription
    > There is a a Free (F0) pricing tier, but warning... you'll use it up fast with testing

2. You have several front-facing face images to use for the same person.
 
## How to setup the project for yourself.
This is the basics of how to use the script or create your own.

1. Sync or copy the FRecognition.ps1 script to your local machine.
2. Create the following folders in the folder containing the Powershell script:
    - PeopleGroups
        - _PersonGroupID_ - The folder name needs to be the one you use when running the script later
    - Test Faces
3. In **File Explorer**, navigate to the PowerShell file, right-click on the file and click **Edit** to open it in Windows PowerShell ISE.
    > You can just open Windows PowerShell ISE and navigate to the folder containing the file if you want.
    
4. Log into the [Azure management portal](http://portal.azure.com)
5. Copy one of your access keys:
    1. Open your Cognitive Services Face API subscription.
    2. On the **Overview** blade, under **Essentials** click **Show access keys...**
    3. Next to **KEY 1** text box, click **Click to copy**.
    
6. In Windows PowerShell, in the console pane, type the following command:
    ```posh
     .\FRecognition.ps1 -cogSubscriptionKey <subscriptionkey> -cogPersonGroupID <persongroupid> -cogPersonGroupName <persongroupname> -cogPerson <person>
     ```
     
     where you replace <subscriptionkey> with the access key you copied from Azure, <persongroupid> is the unique id (no spaces) for the person group used to store images of people, 
     <persongroupname> is the name of the person group (can contain spaces), and <person> is the name of the person whose images you will upload.
     
 7. Press Enter.
 
 You should see output similar to the following:
 
 ```posh
 True
 0.82017
 ```
 
 The first line is the result of the verification, indicating if the service believes the test image matches the one(s)
 uploaded to the person group. 
 
 The second line is the level of confidence in the results, expressed as a percentage.
 
There is some limited error handling in the test file.  We check for the required subfolders and to make sure there are images in them, for example.
Also, there is a try/catch for the REST call that creates the person group, because you will receive an error if you try and create a group with an ID that alrady exists.
Even if you do get an error in that step.

 
