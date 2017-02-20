//
//  OKAutomationPilotableHTTPServer.h
//  DynamicServer
//
//  Created by Bergoin Richard on 09/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OTKMockResponse;
@class OTKRecordedRequest;

#define GET @"GET"
#define POST @"POST"
#define PUT @"PUT"
#define DELETE @"DELETE"
#define PATCH @"PATCH"

@interface OTKPilotableHTTPServer : NSObject

/**
 Responses delay (0.1 by default)
 */
@property (nonatomic, assign) NSTimeInterval responsesDelay;
@property (nonatomic, assign) NSInteger port;
@property (nonatomic, assign) BOOL discoverableViaBonjour;

/*
 * Setting the port number to zero, means the server will automatically use any available port.
 */
- (BOOL)configureAndStartServerWithDocumentRoot:(NSString *)pathToRoot;
- (UInt16)listeningPort;
- (void)stop;
- (NSString *)baseURL;

#pragma mark -

- (NSString *)enqueueMockResponse:(OTKMockResponse *)mockResponse;

- (NSString *)makeRequestForVerb:(NSString *)httpVerb
                          onPath:(NSString *)path
                returnDataOfFile:(NSString *)dataFilePath
                      statusCode:(NSInteger)statusCode
                    serveForever:(BOOL)serveForever;

- (NSString *)makeRequestForGETOnPath:(NSString *)path
                     returnDataOfFile:(NSString *)dataFilePath;

- (NSString *)makeRequestTimeoutForVerb:(NSString *)httpVerb
                                 onPath:(NSString *)path;

- (NSString *)makeRequestForVerb:(NSString *)httpVerb
                          onPath:(NSString *)path
              beRedirectedToPath:(NSString *)toPath;

/**
 Return true if current queue only contain serverForever OTKMockResponse
 */
- (BOOL)hasServedAllQueuedResponses;

- (OTKRecordedRequest *)firstRecordedRequestForVerb:(NSString *)httpVerb
                                             onPath:(NSString *)path;


- (void)log:(NSString *)log;

@end
