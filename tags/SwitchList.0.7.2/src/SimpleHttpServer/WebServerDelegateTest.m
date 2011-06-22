//
//  WebServerDelegateTest.m
//  SwitchList
//
//  Created by bowdidge on 4/16/11.
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

#import "WebServerDelegateTest.h"

#import <Cocoa/Cocoa.h>

#import "FakeSwitchListDocument.h"
#import "WebServerDelegate.h"

@interface MockSimpleHTTPServer : NSObject {
 @public
	int lastCode;
	NSDictionary *lastHeaders;
	NSData *lastBody;
	NSString *lastType;
	NSString *lastMessage;
}

- (void)replyWithStatusCode:(int)code
                    headers:(NSDictionary *)headers
                       body:(NSData *)body;
- (void)replyWithData:(NSData *)data MIMEType:(NSString *)type;
- (void)replyWithStatusCode:(int)code message:(NSString *)message;
@end

@implementation MockSimpleHTTPServer
- (id) init {
	[super init];
	lastCode = 0;
	lastHeaders = nil;
	lastBody = nil;
	lastType = nil;
	lastMessage = nil;
}

- (void) clearState {
	lastCode = 0;
	[lastHeaders release];
	lastHeaders = nil;
	[lastBody release];
	lastBody = nil;
	[lastType release];
	lastType = nil;
	[lastMessage release];
	lastMessage = nil;
}

- (void) dealloc {
	[self clearState];
	[super dealloc];
}

- (void)replyWithStatusCode:(int)code
                    headers:(NSDictionary *)headers
                       body:(NSData *)body {
	[self clearState];
	lastCode = code;
	lastHeaders = [headers retain];
	lastBody = [body retain];
}

- (void)replyWithData:(NSData *)data MIMEType:(NSString *)type {
	[self clearState];
	lastBody = [data retain];
	lastType = [type retain];
}

- (void)replyWithStatusCode:(int)code message:(NSString *)message {
	[self clearState];
	lastCode = code;
	lastMessage = [message retain];
}

- (void) stopResponding {
}

@end

@implementation WebServerDelegateTest
- (void) setUp {
	[super setUp];
	// Needed files need to be in the unit test's main bundle.
	NSBundle *unitTestBundle = [NSBundle bundleWithIdentifier: @"com.blogspot.vasonabranch.Unit tests"];
	server_ = [[MockSimpleHTTPServer alloc] init];
	webServerDelegate_ = [[WebServerDelegate alloc] initWithAppDelegate: nil
															 withServer: (SimpleHTTPServer*) server_
															 withBundle: unitTestBundle];
}

- (void) tearDown {
	// Remove any documents we created in the test.
	NSArray *documents = [[NSDocumentController sharedDocumentController] documents];
	for (NSDocument *document in documents) {
		[[NSDocumentController sharedDocumentController] removeDocument: document];
	}
	[webServerDelegate_ release];
	webServerDelegate_ = nil;
}
	
- (void) testSwitchlistIPhoneCss {
	// TODO(bowdidge): Fails.
	NSURL *url = [NSURL URLWithString: @"http://localhost/switchlist-iphone.css"];
	[webServerDelegate_ processURL: url connection: nil];
	
	STAssertTrue(200 < [server_->lastBody length], @"Not enough bytes in switchlist-iphone.css (should be > 200");
}
				  
- (void) testSwitchlistCss {
	NSURL *url = [NSURL URLWithString: @"http://localhost/switchlist.css"];
	[webServerDelegate_ processURL: url connection: nil];
		  
	STAssertTrue(200 < [server_->lastBody length], @"Not enough bytes in switchlist.css (should be > 200");
}

- (void) testSwitchlistIpadCss {
	NSURL *url = [NSURL URLWithString: @"http://localhost/switchlist-ipad.css"];
	[webServerDelegate_ processURL: url connection: nil];
	
	STAssertTrue(200 < [server_->lastBody length], @"Not enough bytes in switchlist-ipad.css (should be > 200");
}

- (void) testRoot {
	NSURL *url = [NSURL URLWithString: @"http://localhost/"];
	[webServerDelegate_ processURL: url connection: nil];
	
	STAssertTrue([server_->lastMessage rangeOfString: @"No layouts"].length != 0,
				 [NSString stringWithFormat: @"Expected %@ in %@", @"No layouts", server_->lastMessage]);
}

- (void) testRedirect {
	[[NSDocumentController sharedDocumentController] addDocument: [[FakeSwitchListDocument alloc] init]];
	NSURL *url = [NSURL URLWithString: @"http://localhost/"];
	[webServerDelegate_ processURL: url connection: nil];
	
	NSLog(@"Code: %d, Body: %@, Headers: %@, LastMessage: %@", 
		  server_->lastCode, server_->lastBody, server_->lastHeaders, server_->lastMessage);
	
	STAssertTrue([server_->lastMessage rangeOfString: @"REFRESH"].length != 0,
				 [NSString stringWithFormat: @"Expected %@ in %@", @"REFRESH", server_->lastMessage]);
	
}
- (void) testTwoLayouts {
	NSDocumentController *sharedDocumentController = [NSDocumentController sharedDocumentController];
	[sharedDocumentController addDocument: [[FakeSwitchListDocument alloc] init]];
	[sharedDocumentController addDocument: [[FakeSwitchListDocument alloc] init]];
	NSURL *url = [NSURL URLWithString: @"http://localhost/"];
	[webServerDelegate_ processURL: url connection: nil];
	
	NSLog(@"Code: %d, Body: %@, Headers: %@, LastMessage: %@", 
		  server_->lastCode, server_->lastBody, server_->lastHeaders, server_->lastMessage);

	// Make sure we have the links to at least one layout.
	STAssertTrue([server_->lastMessage rangeOfString: @"get?layout=untitled"].length != 0,
				 [NSString stringWithFormat: @"Expected %@ in %@", @"get?layout=untitled", server_->lastMessage]);
	
}


	
@end
