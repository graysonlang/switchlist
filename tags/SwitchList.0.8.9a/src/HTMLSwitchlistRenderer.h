//
//
//  HTMLSwitchlistRenderer.h
//  SwitchList
//
//  Created by bowdidge on 8/30/2011
//
// Copyright (c)2011 Robert Bowdidge,
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
// OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
// OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
// SUCH DAMAGE.
//

// HTMLSwitchlistRenderer: Hide the details of where to find switchlist
// template files, and how to turn the templates into HTML.

#import <Cocoa/Cocoa.h>

@class MGTemplateEngine;
@class ScheduledTrain;
@class EntireLayout;

@interface HTMLSwitchlistRenderer : NSObject {
	// Shared copy of mainBundle object to minimize calls to [NSBundle mainBundle].
	NSBundle *mainBundle_;
	// Template renderer object.
	MGTemplateEngine *engine_;
	// Directory containing user's preferred set of switchlist templates.
	NSString* templateDirectory_;
}

// Create a new HTMLSwitchlistRenderer.
//   bundle: pointer to app's main bundle, used for finding default switchlist files.
- (id) initWithBundle: (NSBundle*) bundle;

// Directory containing current switchlist template.  Needed for finding CSS files
// after rendering.
- (NSString*) templateDirectory;

// Sets the current template used for switchlists to the named template.
// The user's application support folder (~/Library/Application Support/SwitchList) will be
// searched first, followed by the Resources directory of the application bundle.
// If no directory with the template's name is found in either directory or if the
// template name is nil, then the default switchlist will be used.
- (void) setTemplate: (NSString*) templateName;	
- (NSString *) filePathForSwitchlistIPadCSS;
- (NSString *) filePathForSwitchlistIPhoneCSS;
- (NSString *) filePathForSwitchlistCSS;
- (NSString *) filePathForSwitchlistHTML;
- (NSString *) filePathForSwitchlistIPhoneHTML;
	
- (NSString *) renderSwitchlistForTrain: (ScheduledTrain*) train layout: (EntireLayout*)layout iPhone: (BOOL) isIPhone;
- (NSString*) renderCarlistForLayout: (EntireLayout*) layout;
- (NSString*) renderIndustryListForLayout: (EntireLayout*) layout;
- (NSString*) renderLayoutPageForLayout: (EntireLayout*) layout;
- (NSString*) renderLayoutsPage;

@end