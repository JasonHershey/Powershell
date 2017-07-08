# Azure Cognitive Services Voice (Speaker) Recognition API test

This script is a short example/test of the Azure cognitive services voice recogntion apis.  You can find more details about these apis 
at [Speaker Recognition APIs](https://azure.microsoft.com/en-us/services/cognitive-services/speaker-recognition/).
My purpose in creating the script is to make sure I understand how the APIs work.  Im a big fan of PowerShell and I find it a great place
to prototype code, since I have a high level of confidence I know what I'm doing here.  For these apis, my next move will be some JavaScript work 
in NodeJS, where I'm still a beginner.  Hope you find this useful/interesting.

Beyond the standard prerequisites for running scripts, this example assumes the following:
1. You have an Azure Subscription and you added a Cognitive Services Speaker Recognition API subscription
    > There is a a Free (F0) pricing tier, but warning... you'll use it up fast with testing

2. You have created a WAV file that meets the requirements of the service.  The requirements of the file are:
    - WAV format
    - PCM encoding
    - Sample rate: 16K
    - Sample format: 16 bit
    - Channels: Mono
    
    > I use [Audacity](https://sourceforge.net/projects/audacity/) for stuff like this. My next 'test' will be to create a web app, 
    > but that is for another time.
    
    
## How to setup the project for yourself.
This is the basics of how to use the script or create your own.

1. Record one of the [verification phrases](https://azure.microsoft.com/en-us/services/cognitive-services/speaker-recognition/) in Audacity
or your favorite audio program.
2. Export the recording in the proper format (see above).
3. Sync or copy the VRecognition.ps1 script to your local machine.
4. In **File Explorer**, navigate to the file, right-click on the file and click **Edit** to open it in Windows PowerShell ISE.
    > You can just open Windows PowerShell and navigate to the folder containing the file if you want.
    
5. Log into the [Azure management portal](http://portal.azure.com)
6. Copy one of your access keys:
    1. Open your Cognitive Services Speaker Recognition subscription.
    2. On the **Overview** blade, under **Essentials** click **Show access keys...**
    3. Next to **KEY 1** text box, click **Click to copy**.
    
7. In Windows PowerShell, in the console pane, type the following command:
    ```posh
     .\VRecognition.ps1 -cogSubscriptionKey <subscriptionkey> -cogWavFile <wavefilepath> -cogLocale <locale>
     ```
     
     where you replace <subscriptionkey> with the access key you copied from Azure, <wavefilepath> is the path to the WAV file you created earlier
     and <locale> is either the string **en-US** or **zh-CN**  (US English or Mandarin Chinese)
     
 8. Press Enter.
 
 You should see output similar to the following:
 
 ```posh
 Accept
 High
 houston we have had a problem
 ```
 
 The first line is the result of the verification, indicating if the service believes the voice in the file passed during verification matches the one(s)
 used for enrollment. It should match, since it is the same file.
 
 The second line is the level of confidence in the results. It should be High since we are using the same WAV file for enrollment and verification.
 
 The last line is the verification phrase used. This will change depending on which phrase you used for your recording.
 
 If you get errors, then you probably did something wrong or something has changed with the service.  There really is no error checking in this test file.
 
 Hope you have fun!  I'm looking forward to playing with these services some more.
 
