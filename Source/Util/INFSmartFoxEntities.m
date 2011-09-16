//
//  INFSmartFoxEntities.m
//  OkeyiPhoneClient
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#import "INFSmartFoxEntities.h"

@implementation INFSmartFoxEntities

static NSMutableDictionary *ascTab = nil;
static NSMutableDictionary *ascTabRev = nil;
static NSMutableDictionary *hexTable = nil;

+ (void)initialize
{
	if (!ascTab) {
		ascTab = [[NSMutableDictionary dictionaryWithObjectsAndKeys:
				  @"&gt;", @">",
		 		  @"&lt;", @"<",
		 		  @"&amp;", @"&",
		 		  @"&apos;", @"'",
		 		  @"&quot;", @"\"",
				  nil] retain];
	}
	
	if (!ascTabRev) {
		ascTabRev = [[NSMutableDictionary dictionaryWithObjectsAndKeys:
					 @">", @"&gt;",
					 @"<", @"&lt;",
					 @"&", @"&amp;",
					 @"'", @"&apos;",
					 @"\"", @"&quot;",
					 nil] retain];
	}
	
	if (!hexTable) {
		hexTable = [[NSMutableDictionary dictionaryWithObjectsAndKeys:
					[NSNumber numberWithInt:1], @"1",
					[NSNumber numberWithInt:2], @"2",
					[NSNumber numberWithInt:3], @"3",
					[NSNumber numberWithInt:4], @"4",
					[NSNumber numberWithInt:5], @"5",
					[NSNumber numberWithInt:6], @"6",
					[NSNumber numberWithInt:7], @"7",
					[NSNumber numberWithInt:8], @"8",
					[NSNumber numberWithInt:9], @"9",
					[NSNumber numberWithInt:10], @"A",
					[NSNumber numberWithInt:11], @"B",
					[NSNumber numberWithInt:12], @"C",
					[NSNumber numberWithInt:13], @"D",
					[NSNumber numberWithInt:14], @"E",
					[NSNumber numberWithInt:15], @"F",
					nil] retain];
	}
}
	
+ (NSString *)encodeEntities:(NSString *)st
{
	NSString *strbuff = @"";
	
	// char codes < 32 are ignored except for tab,lf,cr
	for (int i = 0; i < [st length]; i++) {
		NSString *ch = [st substringWithRange:NSMakeRange(i, 1)];
		unichar cod = [st characterAtIndex:i];
		
		if (cod == 9 || cod == 10 || cod == 13) {
			strbuff = [strbuff stringByAppendingString:ch];
		}
		else if (cod >= 32 && cod <=126)
		{
			if ([ascTab objectForKey:ch]) {
				strbuff = [strbuff stringByAppendingString:[ascTab objectForKey:ch]];
			}
			else {
				strbuff = [strbuff stringByAppendingString:ch];
			}
		}
		else {
			strbuff = [strbuff stringByAppendingString:ch];
		}
	}
	
	return strbuff;
}

+ (NSString *)decodeEntities:(NSString *)st
{
	NSString *strbuff;
	NSString *ch;
	NSString *ent;
	NSString *chi;
	NSString *item;
	
	NSInteger i = 0;
	
	strbuff = @"";
	
	while (i < [st length])
	{
		ch = [st substringWithRange:NSMakeRange(i, 1)];
		
		if ([ch isEqualToString:@"&"])
		{
			ent = ch;
			
			// read the complete entity
			do
			{
				i++;
				chi = [st substringWithRange:NSMakeRange(i, 1)];
				ent = [ent stringByAppendingString:chi];
			} 
			while (![chi isEqualToString:@";"] && i < [st length]);
				
			item = [ascTabRev objectForKey:ent];
			
			if (item != nil)
				strbuff = [strbuff stringByAppendingString:item];
			else
//				strbuff += String.fromCharCode(getCharCode(ent))
				// TODO
				strbuff = [strbuff stringByAppendingString:ent];
		}
		else
			strbuff = [strbuff stringByAppendingString:ch];
			
		i++;
	};
	
	return strbuff;
}

@end
