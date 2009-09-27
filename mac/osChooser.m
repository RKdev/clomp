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
//  windowsChooser.m
//  SCUBA
//
//  Created by Karl Kuehn on 6/27/08.
//

#import <Cocoa/Cocoa.h>
#import <DiskArbitration/DiskArbitration.h>

#import "osChooser.h"
#include <assert.h> // remember to set NDEBUG for the deployment version

#pragma mark Setting Values


@implementation osChooser

// the bits needed by the interface
@synthesize logoImage;
@synthesize windowTitle;
@synthesize windowMessage;
@synthesize confirmSheetTitle;
@synthesize confirmSheetMessage;

// to make sure that it gets saved properly
@synthesize windowsTargetVolume;

- (id) init {
	self = [super init];

	NSLog_notice(@"Initalizing");
	
	#pragma mark read in defaults from the plists
	NSUserDefaults * myDefaults = [NSUserDefaults standardUserDefaults];
	
	#pragma mark display window settings
	NSLog_info(@"display window settings");
	#pragma mark - top message
	if ([myDefaults objectForKey:WINDOW_TITLE_KEY] != nil) {
		[self setWindowTitle:[myDefaults stringForKey:WINDOW_TITLE_KEY]];
		NSLog_debug(@"window title (user): %@", windowTitle);
	} else {
		windowTitle = @"Reboot into Windows XP";
		NSLog_debug(@"window title (default): %@", windowTitle);
	}
	#pragma mark - bottom message
	if ([myDefaults objectForKey:WINDOW_MESSAGE_KEY] != nil) {
		[self setWindowMessage:[myDefaults stringForKey:WINDOW_MESSAGE_KEY]];
		NSLog_debug(@"window message (user): %@", windowMessage);
	} else {
		windowMessage = @"Click on the Windows logo to reboot into Windows XP";
		NSLog_debug(@"logo message (default): %@", windowMessage);
	}
	#pragma mark - logo image
	if ([myDefaults objectForKey:IMAGE_NAME_OR_PATH_KEY] != nil) {
		NSString * nameOrLocation = [myDefaults stringForKey:IMAGE_NAME_OR_PATH_KEY];
		
		if ([nameOrLocation isAbsolutePath]) {
			NSLog_debug(@"logo image - absolute path (user): %@", nameOrLocation);
			[self setLogoImage:[[NSImage alloc] initWithContentsOfFile:nameOrLocation]];
		} else {
			NSLog_debug(@"logo image - image name (user): %@", nameOrLocation);
			[self setLogoImage:[NSImage imageNamed:nameOrLocation]];
		}
	}
	if (logoImage == nil) {
		NSLog_info(	@"No image was found for the logo, or the preference was not set. Using the default image");
		[self setLogoImage:[NSImage imageNamed:IMAGE_NAME_OR_PATH_DEFAULT]];
		if (logoImage == nil) {
			NSLog_warn(@"Unable to find the default image: %@", IMAGE_NAME_OR_PATH_DEFAULT);
		}
	}
	
	#pragma mark confirmation sheet settings
	NSLog_info(@"confirmation sheet settings");
	#pragma mark - title
	if ([myDefaults objectForKey:CONFIRM_SHEET_TITLE_KEY] != nil) {
		[self setConfirmSheetTitle:[myDefaults stringForKey:CONFIRM_SHEET_TITLE_KEY]];
		NSLog_debug(@"sheet title (user): %@", confirmSheetTitle);
	} else {
		confirmSheetTitle = CONFIRM_SHEET_TITLE_DEFAULT;
		NSLog_debug(@"sheet title (default): %@", CONFIRM_SHEET_TITLE_DEFAULT);
	}
	#pragma mark - text
	if ([myDefaults objectForKey:CONFIRM_SHEET_MESSAGE] != nil) {
		[self setConfirmSheetMessage:[myDefaults stringForKey:CONFIRM_SHEET_MESSAGE]];
		NSLog_debug(@"sheet message (user): %@", confirmSheetMessage);
	}else {
		confirmSheetMessage = CONFIRM_SHEET_MESSAGE_DEFAULT;
		NSLog_debug(@"sheet message (default): %@", CONFIRM_SHEET_MESSAGE_DEFAULT);
	}
	#pragma mark - countdown
	if ([myDefaults objectForKey:CONFIRM_SHEET_TIMEOUT_KEY] != nil) {
		confirmSheetTimeout = [myDefaults doubleForKey:CONFIRM_SHEET_TIMEOUT_KEY];
		NSLog_debug(@"confirmation timeout seconds (user): %.1f", confirmSheetTimeout);
	} else {
		confirmSheetTimeout = CONFIRM_SHEET_TIMEOUT_DEFAULT;
		NSLog_debug(@"confirmation timeout seconds (default): %.1f", CONFIRM_SHEET_TIMEOUT_DEFAULT);
	}
		
	#pragma mark server options
	NSLog_info(@"server settings");
	#pragma mark - server address
	if ([myDefaults objectForKey:SERVER_ADDRESS_KEY] != nil) {
		serverAddress = [[NSURL URLWithString:[myDefaults stringForKey:SERVER_ADDRESS_KEY]] retain];
		NSLog_debug(@"server address (user): %@", [serverAddress absoluteString]);
	} else {
		serverAddress = nil;
		NSLog_debug(@"server address (default): none");
	}
	#pragma mark - ignore server
	if (serverAddress != nil) {
		if ([myDefaults objectForKey:SERVER_IGNORE_KEY] != nil) {
			ignoreServer = [myDefaults boolForKey:SERVER_IGNORE_KEY];
			NSLog_debug(@"ignore server (user): %s", (ignoreServer ? "True" : "False"));
		} else {
			ignoreServer = SERVER_IGNORE_DEFAULT;
			NSLog_debug(@"ignore server (default): %s", (SERVER_IGNORE_DEFAULT ? "True" : "False"));
		}
	} else {
		ignoreServer = TRUE; // if there is no server, we can't pay attention to it
		NSLog_debug(@"no server - ignore server: True");
	}
	#pragma mark - seconds between checks
	if (serverAddress != nil && [myDefaults objectForKey:SERVER_CHECKIN_DELAY_KEY] != nil) {
		secondsBetweenChecks = [myDefaults floatForKey:SERVER_CHECKIN_DELAY_KEY];
		NSLog_debug(@"seconds between checks (user): %.1f", secondsBetweenChecks);
	} else {
		secondsBetweenChecks = SERVER_CHECKIN_DELAY_DEFAULT;
		NSLog_debug(@"seconds between checks (default): %.1f", SERVER_CHECKIN_DELAY_DEFAULT);
	}
	
	#pragma mark reboot into windows settings
	NSLog_info(@"reboot into windows settings");
	#pragma mark - windowsAllowed
	if ([myDefaults objectForKey:WINDOWS_ALLOWED_KEY] != nil) {
		windowsAllowed = [myDefaults boolForKey:WINDOWS_ALLOWED_KEY];
	} else {
		windowsAllowed = WINDOWS_ALLOWED_DEFAULT;
	}
	#pragma mark - target volume
	if ([myDefaults objectForKey:WINDOWS_TARGET_VOLUME_KEY] == nil) {
		windowsTargetVolume = nil;
		windowsAllowed = FALSE;
	} else {
		[self setWindowsTargetVolume:[myDefaults stringForKey:WINDOWS_TARGET_VOLUME_KEY]];
		
		#pragma mark TODO: figure out an API method of getting the bootable volumes
		/*
		DASessionRef diskSession = DASessionCreate(kCFAllocatorDefault);
		if (diskSession == NULL) {
			NSLog_error(@"Internal Error: Unable to create DASession");
		} else {
			DADiskRef windowsDisk = DADiskCreateFromBSDName(kCFAllocatorDefault, diskSession, [windowsTargetVolume cStringUsingEncoding:NSASCIIStringEncoding]);
			if (windowsDisk == NULL) {
				NSLog_warn(@"The bsd path: '%@' is either invalid, or the disk does not exist", windowsTargetVolume);
				[self setWindowsTargetVolume:nil];
			} else {
				// check that the disk looks like it could have a windows volume on it
				CFDictionaryRef windowsDiskInfo = DADiskCopyDescription(windowsDisk);
				if (windowsDiskInfo != NULL) {
					// DAVolumeKind
					CFStringRef filesystemType = (CFStringRef)CFDictionaryGetValue(windowsDiskInfo, CFSTR("DAVolumeKind"));
					if (filesystemType == NULL) {
						NSLog_error(@"Internal Error: Unable to get the filesytem type of %@", windowsTargetVolume);
					} else {
						
					}
					
					
					CFRelease(windowsDiskInfo);
				}
				
				CFRelease(windowsDisk);
			}
			CFRelease(diskSession);
		}
		*/
		
		// check to see that the disk exists
		NSTask * checkWindowsDiskTask = [[NSTask alloc] init];
		[checkWindowsDiskTask setLaunchPath:@"/usr/sbin/diskutil"];
		[checkWindowsDiskTask setArguments:[NSArray arrayWithObjects:@"info", windowsTargetVolume, nil]];
		
		NSPipe * pipe = [NSPipe pipe];
		NSFileHandle * fileHandle = [pipe fileHandleForReading];
		[checkWindowsDiskTask setStandardOutput:pipe];
		
		[checkWindowsDiskTask launch];
		NSString * diskInfoOutput = [[NSString alloc] initWithData:[fileHandle readDataToEndOfFile] encoding:NSASCIIStringEncoding];
		
		// now we have to parse it
		NSScanner * myScanner = [NSScanner scannerWithString:diskInfoOutput];
		[myScanner scanUpToString:@"Is bootable" intoString:NULL];
		if ([myScanner scanString:@"Is bootable" intoString:NULL] == YES) {
		
			// and then parse it again for "Microsoft Basic Data" to make sure it is a DOS disk
			myScanner = [NSScanner scannerWithString:diskInfoOutput];
			[myScanner scanUpToString:@"Microsoft Basic Data" intoString:NULL];
			if ([myScanner scanString:@"Microsoft Basic Data" intoString:NULL] == YES) {
				// nothing to do, value already set
			} else {
				// otherwise we stick with the default FALSEs
				NSLog_warn(@"The disk:%@ was not marked as a Windows-capable volume, so no window will be shown.", windowsTargetVolume);
				[self setWindowsTargetVolume:nil];
			}
		
		} else {
			// otherwise we stick with the default FALSEs
			NSLog_warn(@"The disk:%@ was not bootable, so no window will be shown.", windowsTargetVolume);
			[self setWindowsTargetVolume:nil];
		}
				
		[diskInfoOutput release];
		[checkWindowsDiskTask release];
		
	}
	#pragma mark - helper script path
	if ([myDefaults objectForKey:WINDOWS_HELPER_SCRIPT_PATH_KEY] != nil) {
		rebootIntoWindowsScriptPath = [myDefaults stringForKey:WINDOWS_HELPER_SCRIPT_PATH_KEY];
		NSLog_debug(@"force visable window (user): %@", rebootIntoWindowsScriptPath);
	} else {
		rebootIntoWindowsScriptPath = nil;
	}
		
	#pragma mark debugging settings
	#pragma mark - forceVisableWindow
	if ([myDefaults objectForKey:DEBUG_FORCE_VISIBLE_WINDOW_KEY] != nil) {
		forceVisibleWindow = [myDefaults boolForKey:DEBUG_FORCE_VISIBLE_WINDOW_KEY];
		NSLog_debug(@"force visable window (user): %s", (forceVisibleWindow ? "True" : "False"));
	} else {
		forceVisibleWindow = DEBUG_FORCE_VISIBLE_WINDOW_DEFAULT;
	}
	#pragma mark - just testing setting
	if ([myDefaults objectForKey:DEBUG_DISABLE_REBOOT_KEY] != nil) {
		disableReboot = [myDefaults boolForKey:DEBUG_DISABLE_REBOOT_KEY];
		NSLog_debug(@"disable reboot (user): %s", (disableReboot ? "True" : "False"));
	} else {
		disableReboot = DEBUG_DISABLE_REBOOT_DEFAULT;
	}
	
	return self;
}

- (void) awakeFromNib {
	NSLog_notice(@"Starting check with server");
	[self checkWithServer:nil];
	
	//serverFirstCheckinTimer = [[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(checkWithServer:) userInfo:nil repeats:NO] retain];

	NSLog_info(@"Starting checks every %.1f seconds", secondsBetweenChecks);
	serverCheckinTimer = [[NSTimer scheduledTimerWithTimeInterval:secondsBetweenChecks target:self selector:@selector(checkWithServer:) userInfo:nil repeats:YES] retain];	
}

- (IBAction) rebootIntoWindowsFirstClick:(id)sender {
	if (([[NSApp currentEvent] modifierFlags] & NSShiftKeyMask) != 0) {
		// the shift key was held down, so don't ask
		[self rebootIntoWindows];
	} else {
		modalRebootSheet = [NSAlert alertWithMessageText:confirmSheetTitle defaultButton:@"Cancel" alternateButton:@"Reboot Now" otherButton:nil informativeTextWithFormat:confirmSheetMessage, confirmSheetTimeout];
		[(NSWindow *)[modalRebootSheet window] setCanBecomeVisibleWithoutLogin:YES];

		modalRebootTimer = [NSTimer timerWithTimeInterval:(NSTimeInterval)confirmSheetTimeout target:self selector:@selector(rebootSheetTimeout:) userInfo:nil repeats:NO];
		[[NSRunLoop currentRunLoop] addTimer:modalRebootTimer forMode:NSDefaultRunLoopMode];

		[modalRebootSheet beginSheetModalForWindow:targetWindow modalDelegate:self didEndSelector:@selector(rebootSheetChoice: returnCode: contextInfo:) contextInfo:nil]; 
	}
}

- (void) rebootSheetTimeout:(NSTimer *) theTimer {
	// If we get here then the 10 second timer has gone off, and we need to call reboot into Windows
	NSLog_notice(@"Confirmation sheet timed out, rebooting into Windows");
	[[NSApplication sharedApplication] endSheet: [modalRebootSheet window]];
	[modalRebootTimer invalidate];
	[self rebootIntoWindows];
}

- (void) rebootSheetChoice:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	// the user has chosen a button, and we need to cancel the timeout, and set it going if the user has not chosen cancel
	[modalRebootTimer invalidate];
	
	if (returnCode != NSAlertDefaultReturn) {
		// they did not press cancel
		NSLog_notice(@"User chose to reboot into windows");
		[self rebootIntoWindows];
	} else {
		NSLog_notice(@"User chose cancel");
	}
}

- (void) rebootIntoWindows {
	NSLog_notice(@"Rebooting into Windows");
	
	assert(windowsTargetVolume != nil || forceVisibleWindow == TRUE);
	
	if (windowsTargetVolume == nil) {
		NSBeep();
		
		if (forceVisibleWindow) {
			if (rebootIntoWindowsScriptPath == nil) {
				NSLog_info(@"Would have used the bless method to setup the windows boot, but 'Force Visible Window' is on and there is no Windows volume");
			} else {
				NSLog_info(@"Would have used external item: %@ to setup the windows boot, but 'Force Visible Window' is on and there is no Windows volume", rebootIntoWindowsScriptPath);
			}
			return;
		}
		NSLog_error(@"Tried to reboot into Windows, but there is no valid Windows volume");
		return;
	}
	
	NSTask * setupTask;
	
	if (rebootIntoWindowsScriptPath == nil) {
		if (disableReboot) {
			NSLog_info(@"Would have rebooted into Windows using bless method, but 'Disable Reboot' is turned on");
			return;
		}
		
		NSLog_info(@"Using the bless method to setup the windows boot");
		setupTask = [NSTask launchedTaskWithLaunchPath:@"/usr/sbin/bless" arguments:[NSArray arrayWithObjects:@"-device", windowsTargetVolume, @"-legacy", @"-setBoot", @"-nextonly", nil]];
	
		// TODO: get the more gentle AppleScript reboot working
		//NSDictionary * error;
		//NSAppleScript * restartScpt = [[[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to restart"] autorelease];
		//[restartScpt executeAndReturnError:&error];
	} else {
		if (disableReboot) {
			NSLog_info(@"Would have rebooted into Windows using external item: %@, but 'Disable Reboot' is turned on", rebootIntoWindowsScriptPath);
			return;
		}
		NSLog_info(@"Using external item: %@ to setup the windows boot", rebootIntoWindowsScriptPath);
		setupTask = [NSTask launchedTaskWithLaunchPath:rebootIntoWindowsScriptPath arguments:[NSArray array]];
	}
	
	[setupTask waitUntilExit];
	
	if ([setupTask terminationStatus] == 0) { 
		NSLog_notice(@"Rebooting");
		[NSTask launchedTaskWithLaunchPath:@"/sbin/shutdown" arguments:[NSArray arrayWithObjects:@"-r", @"now", nil]];
	} else {
		NSLog_error(@"Setting up to reboot into Windows failed ");
	}

}

- (void) checkWithServer:(NSTimer *) theTimer {
	// this will check in with a server, and see if the reboot to windows should be allowed
	
	assert(targetWindow != nil);
	
	if (windowsTargetVolume == nil) {
		NSLog_info(@"No windows volume");
	} else if (ignoreServer) {
		NSLog_info(@"Ignore server flag is set, so server was not consulted");
	} else {
		assert(serverAddress != nil);
		
		// this next line is because it will sometimes just give us the last responce it got
		[[NSURLCache sharedURLCache] removeAllCachedResponses]; // TODO: be less droconian about this
		
		NSLog_notice(@"Checking with server");
		
		NSString * serverResponse = [NSString stringWithContentsOfURL:serverAddress usedEncoding:NULL error:NULL];
						
		if (serverResponse == nil) {
			NSLog_warn(@"Unable to get configuration from server");
		} else {
			// take the responce apart into lines
			NSArray * responceLines = [serverResponse componentsSeparatedByString:@"\n"];

			BOOL gotServerData = FALSE;
			
			for (NSString * thisLine in responceLines) {
				// TODO: better parsing of the file
				
				if ([thisLine isEqualToString:@""] || [thisLine characterAtIndex:0] == '#') {
					continue; // ignore empty or comment lines
				}
				
				NSArray * parsedLine = [thisLine componentsSeparatedByString:@"="];
				
				if ([parsedLine count] != 2) {
					// this line does not conform to our key=value format
					NSLog_warn(@"Recieved a bad configuration line from the server: %@", thisLine);
				} else {
					if ([[(NSString *)[parsedLine objectAtIndex:0] lowercaseString] compare:@"windowsallowed"] == NSOrderedSame) {
						// WindowsAllowed
						gotServerData = TRUE;
						if ([[(NSString *)[parsedLine objectAtIndex:1] lowercaseString] compare:@"false"] == NSOrderedSame) {
							NSLog_debug(@"Server response: Windows is not allowed");
							windowsAllowed = FALSE;
						} else {
							NSLog_debug(@"Server response: Windows is allowed");
							windowsAllowed = TRUE;
						}
					} else if ([[(NSString *)[parsedLine objectAtIndex:0] lowercaseString] compare:@"macosxallowed"] == NSOrderedSame) {
						// MacOSXAllowed
						gotServerData = TRUE;
						if ([[(NSString *)[parsedLine objectAtIndex:1] lowercaseString] compare:@"false"] == NSOrderedSame) {
							// if MacOS X is not allowed for this computer, then we need to reboot
							NSLog_notice(@"MacOS X is not currently allowed on this computer. Rebooting");
							[self rebootIntoWindows];
						}
					} else {
						NSLog_debug(@"Recieved an unknown configuration from server: %@", thisLine);
					}
				}
			}
			
			if (gotServerData == FALSE) {
				NSLog_info(@"Server returned no useable data");
			}
		}
	}
	
	if (windowsAllowed == FALSE && forceVisibleWindow == TRUE) {
		NSLog_info(@"Window would not normally be show, but 'Force Visible Window' was enabled")
		windowsAllowed = TRUE;
	}
	
	if (windowsTargetVolume == nil) {
		NSLog_info(@"No valid Windows volume, so no window will be shown.");
		#pragma mark TODO: stop this from checking again'
		
	} else if ([targetWindow isVisible] == windowsAllowed) {
		NSLog_debug(@"Window was already %@", (windowsAllowed ? @"visible" : @"hidden"));
	} else {
		if (windowsAllowed) {
			NSLog_notice(@"Showing Window");
			[targetWindow orderFront:self];
		} else {
			NSLog_notice(@"Hiding Window");
			[targetWindow orderOut:self];
		}
	}
}

@end