//
//  INFSmartFoxExtHandler.m
//  OkeyiPhoneClient
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#import "INFSmartFoxExtHandler.h"
#import "INFSmartFoxSFSEvent.h"
#import "INFSmartFoxiPhoneClient.h"
#import "INFSmartFoxObjectSerializer.h"
#import "TouchXML.h"

@implementation INFSmartFoxExtHandler

+ (id)extHandler:(INFSmartFoxiPhoneClient *)sfs
{
	INFSmartFoxExtHandler *obj = [INFSmartFoxExtHandler alloc];
	return [[obj initWithParams:sfs] autorelease];
}

- (id)initWithParams:(INFSmartFoxiPhoneClient *)sfs
{
	self = [super init];
	if (self) {
		_sfs = sfs;
	}
	
	return self;
}

- (void)handleMessage:(id)msgObj type:(NSString *)type delegate:(id <INFSmartFoxISFSEvents>)delegate
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxExtHandler:handleMessage msgObj:%@", msgObj]];

	if ([type isEqualToString:(NSString *)_sfs.INFSMARTFOXCLIENT_XTMSG_TYPE_XML]) {
		NSError *error;
		CXMLDocument *doc;
		
		doc = [[CXMLDocument alloc] initWithXMLString:msgObj options:0 error:&error];
		
		NSString *action = [[[doc nodesForXPath:@"./msg/body/@action" error:&error] objectAtIndex:0] stringValue];
		NSString *xmlData = [[[doc nodesForXPath:@"./msg/body" error:&error] objectAtIndex:0] stringValue];
		
		if ([action isEqualToString:@"xtRes"]) {
			NSDictionary *asObj = [INFSmartFoxObjectSerializer deserialize:xmlData];
			// Fire event!
			if ([_sfs.delegate respondsToSelector:@selector(onExtensionResponse:)]) {		
				[_sfs.delegate onExtensionResponse:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																				  asObj, @"dataObj",
																				  type, @"type",
																				  nil]]];			
			}
		}
		
		[doc release];		
	}
	else {
//	else if ([type isEqualToString:(NSString *)_sfs.INFSMARTFOXCLIENT_XTMSG_TYPE_JSON]) {		
//	else if ([type isEqualToString:(NSString *)_sfs.INFSMARTFOXCLIENT_XTMSG_TYPE_STR]) {
		// Fire event!
		if ([_sfs.delegate respondsToSelector:@selector(onExtensionResponse:)]) {		
			[_sfs.delegate onExtensionResponse:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																			  msgObj, @"dataObj",
																			  type, @"type",
																			  nil]]];			
		}	
	}																 
}

@end
