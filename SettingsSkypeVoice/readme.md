# Skype for Business/Teams Phone System - Change Autoattendant voices with Powershell

Skype (or Teams) Phone System is not the best documented set of features in Office 365.
The basics are [documented here](https://docs.microsoft.com/microsoftteams/cloud-voice-landing-page).
But, some of the finer details that make clients happy are missing.

For example, I recently setup an Autoattendant for a client, but they didn't like the computer generated voice.  They had someone in their company record custom greetings and we uploaded those.

But, guess what?  There are still some computer generated voices that you can't replace with a recording.  However, you do have some capability to customize the computer generated voice -- with Powershell.

So, I've created a simple script you can use for customizing your Autoattendant.

Before you begin, if you have not done so already, you need to download the MSOL sign-on assistant from [here](https://www.microsoft.com/en-us/download/details.aspx?id=41950).

# Overview of the script

The script is commented, but here are the basics of what it does:

1. Gets your O365 credentials 
2. Connects to O365 using 
3. Install the SFBO module 
4. Create/Import a remote SFBO session
5. Gets a list of supported Autoattendant languages \(just for the heck of it\)
6. Sets a variable as the EN-US Autoattendant langauge.
  The language contains the voices.

7. Sets a variable as the **Benjamin** voice.
  The EN-US language has 3 female voices and 1 mail voice.

8. Gets your organizational Autoattendants. \(so you can see the settings. You need to see the URI's\)
9. Now set a variable as the specific Autoattendant, based on the SIP URI.
10. Set the Autoattendant's voice as the Benjamine voice \(the variable created earlier\).
11. and finally confirm the Voice of the Autoattendant

That's it!

Now, experiment with the voices and see which ones




