# PSH-AdminToolBox
Powershell can save a lot of time or create a huge headache if you are working as an system administrator :-). Because I also often searched the web for ideas or solutions for a problem, I now want to spread my work to give some help for others who got stuck in similar situations - **_so keep calm and let the sysadmin handle it_**

## Scripts
The default location of code I develop (most just 'scripts' and no 'functions') because not all of the scripts I create are needed in daily tasks, so I don´t save them in my 'AdminToolbox' module.
#### get-RandomPassword
Easy to use script to get a randomized password based on a predfined 'salt'#
#### Restart-Services-InOrder
Often I got to the situation that a user (or power user) should be able to take a bit care of "his application" on a server without acting like a admin. 
For example it often helps to just restart some services but to explain a user how to do this in the right way is not always easy. 
With this little tool you could define a list of services (including a user friendly desrription) an also define a priority in which order the services should be processed. Together with the option to stop/start them in reverse order you could grant the user only to log on by RDP and just stop/start the named services in the script (see helpfile in script for further information). Additionally all action can be stored in a log file so the last action(s) could be checked afterwards. 

I am using this on several servers and the users are verry happy with it because they just have to hit an icon on the desktop and select an option. Together with the logfiles it is always clear who did which action when.

## Modules
Those scripts I needed most got wrapped in a 'function' and stored in my 'module' so the are small building blocks in an modular working 'AdminToolbox'.
#### Convert-DN
Often was bored dealing with 'distinguished names' to extract information from it (like OU where user is located..why is there no value directly for that). This one is the answer to extract the info I needed most
#### Convert-SpecialChars
During my progress creating scripts for 'sync object from VMware hypervisor to Active Directory' I needed this to clear chars for using in setting the descrition of computerobjects afterwards
#### Convert-Umlaut
During my progress creating a script for 'user creation automation' this one get handy to remove/treat specials chars used in german surname/givennmae which can´t be used in a samaccountname or something similar - currently I think we in Germany are the only ones translating a 'ü' to 'ue' for example
##### Convert-UmlautCyrillic
During my progress creating a script for 'user creation automation' this one get handy to remove/treat specials chars used in surname/givennmae which can´t be used in a samaccountname or something similar

### Support me a bit :-)
If you buy me a coffe you not just support my 'daily fuel' to keep my brain running smooth, but you also motivate me to further improve my work. 
It also gives me a good feeling someone else likes what I have done or maybe has also a benefet at his job through using a script of mine :-)

<a href="https://www.buymeacoffee.com/Wapiya"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&emoji=&slug=Wapiya&button_colour=BD5FFF&font_colour=ffffff&font_family=Cookie&outline_colour=000000&coffee_colour=FFDD00"></a>
