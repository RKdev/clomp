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
//  boarderlessWindow.h
//  SCUBA
//
//  Created by Karl Kuehn on 6/27/08.
//

#import <Cocoa/Cocoa.h>

static CGFloat loginWindowTopHeight				= 179	// pixels from the top to the top of the login area (not including LoginwindowText height)
static CGFloat loginWindowBottomHeight			= 78	// pixels from the bottom of the login area to the bottom of the window

static CGFloat loginWindowMessageHeight			= 22	// pixels added to the loginwindow if there is a LoginwindowText message

static CGFloat loginWindowChooserBaseHeight		= 41	// pixels with no users in the chooser version
static CGFloat loginWindowChooserPerUserHeight	= 60	// pixels added per user in the chooser version

static CGFloat loginWindowNameAndPasswordHeight	= 100	// pixels tall of the name-and-password version

static CGFloat loginWindowVerticalCenterOffset	= 19	// pixels above center for the loginwindow

@interface BorderlessWindow : NSWindow {
	NSTimer * windowRefreshTimer;
}

- (void) showWindow;
- (void) hideWindow;
- (void) positionWindowOnSceen;

@end
