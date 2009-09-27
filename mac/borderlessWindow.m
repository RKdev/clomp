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
//  boarderlessWindow.m
//  SCUBA
//
//  Created by Karl Kuehn on 6/27/08.
//

#import "borderlessWindow.h"

// the login-window is centered, but not on the window as a whole,
//		rather on the area where you choose a user from a list, or type in the name
//		so figuring out where the lower-right corner is is a bit of a trick

static CGFloat loginWindowWidth				= 470.0; // this should be pretty constant

static CGFloat topToMessageText				= 173.0; // this seems to be constant

static CGFloat textBoxSizePerLine			= 16.0;	// there are about 16 pixes of height per line of text
static CGFloat textBoxPadding				= 12.0;	// about 12 pixes of padding if there is any text

static CGFloat nameAndPasswordBoxHeight		= 106.0; // if it is not choosing users from a list

// TODO: figure out how much space users take, and figure out how to get the number of users
//	In the mean times these are just wild guesses
static CGFloat userSpacePerUser				= 60.0;
static CGFloat userSpacePadding				= 48.0;

static CGFloat bottomToBox					= 68.0; // the space between the bottom of the users box and the bottom of the window

static CGFloat spaceBetweenWindows			= 40.0; // the space between the two windows
static CGFloat minimumSpaceBetweenWindows	= 5.0; // if the screen is too small, how small are we willing to go

static CGFloat verticalAdjust				= 0; // an adjust to re-center the window, positive number go down

static int timeToRefresh					= 5; // the window will be re-positioned after this number of seconds to make sure it gets positiond correctly on-screen

@implementation borderlessWindow

- (id) initWithContentRect: (NSRect)contentRect styleMask: (NSUInteger)aStyle backing: (NSBackingStoreType)bufferingType defer:(BOOL)deferCreation {
	return [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:deferCreation];
}

- (void) showWindow {
	while ([self isVisible] == FALSE) {
		[self positionWindowOnSceen];
		sleep(1);
	}
}

- (void) hideWindow {
	while ([self isVisible] == TRUE) {
		[self orderOut];
	}
}

- (void) positionWindowOnSceen {
	
	NSDictionary * loginwindowDefaults = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:@"/Library/Preferences/com.apple.loginwindow.plist"]mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:&myError];

	
	// figure out the size of the loginwindow - only the height is variable
	NSSize loginWindowSize = {loginWindowWidth, loginWindowTopHeight + loginWindowBottomHeight};
	if ([loginwindowDefaults objectForKey:@"LoginwindowText"] != nil) {
		loginWindowSize.height += loginWindowMessageHeight
	}
	
	
	
	return;
	
	
	
	NSUserDefaults * myDefaults = [NSUserDefaults standardUserDefaults];
	
	NSSize loginWindowCenterOffset = {loginWindowWidth / 2, bottomToBox}; // we will add to this
	
	#pragma mark guess loginwindow size
	NSString * myError;
	CGFloat loginWindowHeight = topToMessageText + bottomToBox; // we will add the rest into this
	NSDictionary * loginwindowDefaults = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:@"/Library/Preferences/com.apple.loginwindow.plist"]mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:&myError];
	
	if (loginwindowDefaults == nil || myError != nil) {
		NSLog(@"Unable to get the login-window defaults!");
		[myError release];
		return;
	}
		
	if ([loginwindowDefaults objectForKey:@"LoginwindowText"] != nil) {
		// TODO: figure out how many lines of text are used
		int linesOfText = 1;
		if ([myDefaults objectForKey:@"loginwindowTextLines"] != nil) {
			linesOfText = [myDefaults integerForKey:@"loginwindowTextLines"];
		} 
		loginWindowHeight += (float)(linesOfText * textBoxSizePerLine) + textBoxPadding;
		loginWindowCenterOffset.height += ((float)(linesOfText * textBoxSizePerLine) + textBoxPadding) / 2;
	}
	
	if ([loginwindowDefaults objectForKey:@"SHOWFULLNAME"] != nil && [[loginwindowDefaults objectForKey:@"SHOWFULLNAME"] boolValue]) {
		// the loginwindow is using name & password
		loginWindowHeight += nameAndPasswordBoxHeight;
		
		loginWindowCenterOffset.height += nameAndPasswordBoxHeight / 2;
		
	} else {
		// the loginwindow is using a list of users
		// TODO: figure out how many users are displayed, display more space for a single user for the password box
		int usersDisplayed = 1;
		if ([myDefaults objectForKey:@"loginwindowUsersDisplayed"] != nil) {
			usersDisplayed = [myDefaults integerForKey:@"loginwindowUsersDisplayed"];
		} 
		
		loginWindowHeight += (usersDisplayed * userSpacePerUser) + userSpacePadding;
		
		loginWindowCenterOffset.height += ((usersDisplayed * userSpacePerUser) + userSpacePadding) / 2;
	}
		
	#pragma mark position  and size the window

	// resize the window to the proper size
	NSSize targetSize = {loginWindowWidth, loginWindowHeight};
	[self setContentSize:targetSize];

	// get the screen size
	NSRect screenSize = [[self screen] frame];
	
	float screenMiddleHeight = 0;
	float screenMiddleWidth = 0;
	
	if ( screenSize.size.height > screenSize.size.width ) {
		// there seems to be some odd conditions during the switch to the loginwindow where these ocassionally get reversed
		screenMiddleHeight = screenSize.size.width / 2;
		screenMiddleWidth = screenSize.size.height / 2;
	} else {
		screenMiddleHeight = screenSize.size.height / 2;
		screenMiddleWidth = screenSize.size.width / 2;
	}
	
	// set the location
	NSPoint desiredLocation = { // note that this is the bottom-left of the window
		screenMiddleWidth - loginWindowCenterOffset.width - spaceBetweenWindows - targetSize.width, // horizontal
		screenMiddleHeight - loginWindowCenterOffset.height - verticalAdjust // vertical
	};
	
	if (desiredLocation.x < minimumSpaceBetweenWindows) {
		// this is probably a 13" screen, and we need to re-adjust
		
		// first crowd the space between the windows
		desiredLocation.x += spaceBetweenWindows - minimumSpaceBetweenWindows;
			
		if (desiredLocation.x < minimumSpaceBetweenWindows) {
			// that didn't so it, so we need to change the width of the window. This will affect text display.
			targetSize.width += desiredLocation.x - (2 * minimumSpaceBetweenWindows);
			// adding a negative, and enough space for between windows and away from edge
			desiredLocation.x = minimumSpaceBetweenWindows;

			[self setFrame:(NSRect){desiredLocation, targetSize} display:YES];
		}
	}
	
	//NSLog(@"Screen position: %f x %f", desiredLocation.x, desiredLocation.y);
	
	[self setFrameOrigin:desiredLocation];
	
}

- (BOOL) canBecomeVisibleWithoutLogin {
	return YES;
}

- (BOOL) canBecomeKeyWindow {
	return NO;
}

@end
