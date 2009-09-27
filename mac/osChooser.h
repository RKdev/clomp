/*
		Copyright (c) 2008, Stanford University - Student Computing
		All rights reserved.

		Redistribution and use in source and binary forms, with or without
		modification, are permitted provided that the following conditions are met:
			* Redistributions of source code must retain the above copyright
			  notice, this list of conditions and the following disclaimer.
			* Redistributions in binary form must reproduce the above copyright
			  notice, this list of conditions and the following disclaimer in the
			  documentation and/or other materials provided with the distribution.
			* Neither the name of the Stanford University - Student Computing nor the
			  names of its contributors may be used to endorse or promote products
			  derived from this software without specific prior written permission.

		THIS SOFTWARE IS PROVIDED BY Stanford University - Student Computing ''AS IS'' AND ANY
		EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
		WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
		DISCLAIMED. IN NO EVENT SHALL Stanford University - Student Computing BE LIABLE FOR ANY
		DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
		(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
		LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
		ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
		(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
		SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
//
//  windowsChooser.h
//  SCUBA
//
//  Created by Karl Kuehn on 6/27/08.
//

#include "NSLog_plus.h"

#define WINDOW_TITLE_KEY @"Window Title"
#define WINDOW_MESSAGE_KEY @"Window Message"
#define IMAGE_NAME_OR_PATH_KEY @"Logo Image"
#define IMAGE_NAME_OR_PATH_DEFAULT @"BootWindow"

#define CONFIRM_SHEET_TITLE_KEY @"Confirm Sheet Title"
#define CONFIRM_SHEET_TITLE_DEFAULT @"Reboot into MS Windows XP?"
#define CONFIRM_SHEET_MESSAGE @"Confirm Sheet Message"
#define CONFIRM_SHEET_MESSAGE_DEFAULT @"This computer will reboot into Microsoft Windows in %.0f seconds."
#define CONFIRM_SHEET_TIMEOUT_KEY @"Counfirm Sheet Timeout Seconds"
#define CONFIRM_SHEET_TIMEOUT_DEFAULT 10.0

#define SERVER_ADDRESS_KEY @"Server Check-in URL"
// default address is nil
#define SERVER_IGNORE_KEY @"Ignore Server"
#define SERVER_IGNORE_DEFAULT FALSE
#define SERVER_CHECKIN_DELAY_KEY @"Server Check-in Delay"
#define SERVER_CHECKIN_DELAY_DEFAULT 300.0

#define WINDOWS_ALLOWED_KEY @"Windows Allowed"
#define WINDOWS_ALLOWED_DEFAULT TRUE
#define WINDOWS_TARGET_VOLUME_KEY @"Windows Target Volume"
// default is nil
#define WINDOWS_HELPER_SCRIPT_PATH_KEY @"Windows Helper Script Path"
// default is nil

#define DEBUG_FORCE_VISIBLE_WINDOW_KEY @"Force Visable Window"
#define DEBUG_FORCE_VISIBLE_WINDOW_DEFAULT FALSE
#define DEBUG_DISABLE_REBOOT_KEY @"Disable Reboot"
#define DEBUG_DISABLE_REBOOT_DEFAULT FALSE

@interface osChooser : NSObject {
	
	#pragma mark display window
	IBOutlet BorderlessWindow * targetWindow;
	NSString * windowTitle;					// text displayed at the top of the window
	NSString * windowMessage;				// explanation text under the image
	NSImage	* logoImage;					// the logo that gets shown in the window	
	
	
	#pragma mark countdown sheet
	NSString * confirmSheetTitle;			// title of the countdown sheet
	NSString * confirmSheetMessage;			// text displayed in the sheet, needs a %i for the seconds
	NSTimeInterval confirmSheetTimeout;		// sheet will time out after this number of seconds

	NSAlert * modalRebootSheet;				// holder for the generated sheet
	NSTimer * modalRebootTimer;				// timer for the sheet
	
	#pragma mark server settings
	BOOL ignoreServer;						// server should be ignored
	NSURL * serverAddress;
	NSTimeInterval secondsBetweenChecks;
	
	NSTimer * serverCheckinTimer;
	NSTimer * serverFirstCheckinTimer;
	
	#pragma mark reboot into windows settings
	BOOL hasWindowsVolume;					// if there is no Windows volume, we should not display the screen
	BOOL windowsAllowed;					// the preference if the server cannot be found
	NSString * windowsTargetVolume;			// the disk volume (eg: /dev/disk0s3) where Windows lives
	NSString * rebootIntoWindowsScriptPath;	// if present, the path to the script that wil do the work of rebooting into windows
	
	#pragma mark debugging settings
	BOOL disableReboot;						// disables the actions to reboot into window
	BOOL forceVisibleWindow;				// debug setting to always show the window, and to ignore the absence of a windows volume
}

- (IBAction)rebootIntoWindowsFirstClick:(id)sender;

- (void)rebootIntoWindows;

- (void)checkWithServer: (NSTimer *)timer;

@property(retain) NSImage * logoImage;
@property(retain) NSString * windowTitle;
@property(retain) NSString * windowMessage;

@property(retain) NSString * confirmSheetTitle;
@property(retain) NSString * confirmSheetMessage;

@property(copy) NSString * windowsTargetVolume;

@end
