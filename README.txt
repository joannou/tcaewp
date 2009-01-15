The following is an email to the cocoa-dev mailing list in 2005, sharing and documenting TCAEWP. You can also see the same email at:
http://lists.apple.com/archives/cocoa-dev/2005/Apr/msg00660.html



Subject: Re: User Authentication
From: Joannou Ng <email@hidden>
Date: Sat, 9 Apr 2005 12:37:51 -0400
Delivered-to: email@hidden
Delivered-to: email@hidden

Hi Austin,

I suggest reading up on Authentication and Authorization:
http://developer.apple.com/referencelibrary/Security/idxAuthentication-date.html
http://developer.apple.com/referencelibrary/Security/idxAuthorization-date.html

Then, see what everyone has to say:
http://cocoadev.com/index.pl?search=authentication
http://cocoadev.com/index.pl?search=authorization

Long story short, doing it "right" is a pain in the ass.

One solution that doesn't do it the "right" way is:
https://opensvn.csie.org/bi/KisMACng/Subprojects/BIGeneric/BLAuthentication.h
https://opensvn.csie.org/bi/KisMACng/Subprojects/KisMAC%20Installer/BLAuthentication.m

I wrote something similar to the above a week ago:
http://tomatocheese.com/TCAEWP.h
http://tomatocheese.com/TCAEWP.m

Mine is real simple. And here's how to set it up:
First, add the two files to your project.
Then, drag TCAEWP.h to your nib.
Instantiate it.
In your app controller class or wherever you need to run a command that needs authentication, declare an outlet to my class and connect the outlet between your instance and my instance.
There should only be one instance of my class throughout your app.

Here's how to use it:
There is only one method:
- (NSString *)execute:(NSString *)command arguments:(NSArray *)arguments;
command is the full pathname of the tool to execute.
arguments is an array of arguments to send to the tool.
It will return you the output of the command. Also, it will post a notification for every line of the output.
This allows you to either wait for all of the output returned, or deal with the output line by line through the notification.

Here's how to deal with the return value:
You need to check it for a prefix of TCAEWPFailed using NSString's hasPrefix: method, like so:
if (![output hasPrefix:@"TCAEWPFailed"]) {
// All is good, you now have your output from the command.
} else {
// No go.
}

Here's how to deal with the line notification:
// Register your object to receive the line notification.
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processLine:) name:@"TCAEWPLineNotification" object:aewp];

// Call the method here.
[aewp execute:command arguments:arguments];

// Deregister your object to receive the line notification.
[[NSNotificationCenter defaultCenter] removeObserver:self name:@"TCAEWPLineNotification" object:aewp];

If you, or anyone, chooses to use my class, feedback (both good and bad) is welcomed.

Cheers, Joannou.

On 2005 Apr 09, at 10:55, Austin Sarner wrote:

Hey, I'm working on something that requires information to be written to the /Libary folder which, of course, is write protected. I am willing to require user authentication, preferably giving them the option to add the program to their key chain. What is the best way to go about doing this? The operations I need to perform in the directory are basic file moving or string writing ones.

Thanks a bunch,
Austin Sarner
 _______________________________________________
Do not post admin requests to the list. They will be ignored.
Cocoa-dev mailing list      (email@hidden)
Help/Unsubscribe/Update your Subscription:
http://lists.apple.com/mailman/options/cocoa-dev/email@hidden

This email sent to email@hidden