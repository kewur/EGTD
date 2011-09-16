//
//  INFSmartFoxObjectSerializer.m
//  OkeyiPhoneClient
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#import "INFSmartFoxObjectSerializer.h"
#import "INFSmartFoxEntities.h"
#import "NSObjectAddition.h"
#import "TouchXML.h"

@implementation INFSmartFoxObjectSerializer

static BOOL _debug = FALSE;
static NSString *_eof = @"";
static NSError *error;

/**
 * Set debug
 */
+ (void)setDebug:(BOOL)b
{
	_debug = b;
	
	if (_debug) {
		_eof = @"\n";
	}
	else {
		_eof = @"";
	}
}

+ (void)arrayAndObjectHelper:(id)srcObj trgObj:(NSString **)trgObj depth:(NSInteger)depth objName:(NSString *)objName varName:(NSString *)varName varValue:(id)varValue
{
	NSString *t = @"x";
	NSString *o = @"";
	//
	// if a primitive type is found
	// generate an xml <var n="name" t="type">value</var> TAG
	//
	// n = name of var
	//
	// t = b: boolean
	//     n: number
	//     s: string
	//     x: null
	//
	// v = value of var
	//
	if ([[varValue className] isEqualToString:@"NSCFBoolean"]) {
		t = @"b";
		o = [varValue stringValue];
	}
	else if ([[varValue className] isEqualToString:@"NSCFNumber"]) {
		t = @"n";
		o = [varValue stringValue];
	}		
	else if ([varValue isKindOfClass:[NSString class]] || [[srcObj className] isEqualToString:@"NSCFString"]) {	
		t = @"s";
		o = [INFSmartFoxEntities encodeEntities:varValue];
	}
	else if ([varValue isKindOfClass:[NSNull class]]) {
		t = @"x";
		o = @"";
	}
	
	if (_debug) {
		*trgObj = [*trgObj stringByPaddingToLength:[*trgObj length] + depth + 1 withString:@"\t" startingAtIndex:0];
	}
	
	*trgObj = [*trgObj stringByAppendingFormat:@"<var n='%@' t='%@'>%@</var>%@", varName, t, o, _eof];
}

+ (void)obj2xml:(id)srcObj trgObj:(NSString **)trgObj depth:(NSInteger)depth objName:(NSString *)objName
{
	// First run
	if (depth == 0) {
		*trgObj = [*trgObj stringByAppendingFormat:@"<dataObj>%@", _eof];
	}
	else {
		// Inside a recursive call
		if (_debug) {
			*trgObj = [*trgObj stringByPaddingToLength:[*trgObj length] + depth withString:@"\t" startingAtIndex:0];
		}
		
		// Object type
		NSString *ot;
		
		if ([srcObj isKindOfClass:[NSDictionary class]]) {
			ot = @"o";
		}
		else {
			ot = @"a";
		}
		
		*trgObj = [*trgObj stringByAppendingFormat:@"<obj t='%@' o='%@'>%@", ot, objName, _eof];
	}
	
	// Scan the object recursively
	if ([srcObj isKindOfClass:[NSDictionary class]]) {
		NSEnumerator *enumerator = [srcObj keyEnumerator];
		id i;
		
		while ((i = [enumerator nextObject])) {
			//
			// if an object / array is found
			// recursively scans the new Object
			// and create a <obj o=""></obj> TAG
			//
			// o = object name
			//
			if ([[srcObj objectForKey:i] isKindOfClass:[NSDictionary class]] || [[srcObj objectForKey:i] isKindOfClass:[NSArray class]]) {
				[self obj2xml:[srcObj objectForKey:i] trgObj:trgObj depth:depth + 1 objName:i];
				
				if (_debug) {
					*trgObj = [*trgObj stringByPaddingToLength:[*trgObj length] + depth + 1 withString:@"\t" startingAtIndex:0];
				}
				
				*trgObj = [*trgObj stringByAppendingFormat:@"</obj>%@", _eof];
			}
			else {
				[self arrayAndObjectHelper:srcObj trgObj:trgObj depth:depth objName:objName varName:i varValue:[srcObj objectForKey:i]];
			}
		}		
	}
	else {
		NSEnumerator *enumerator = [srcObj objectEnumerator];
		id o;
		NSInteger i = 0;
		
		while ((o = [enumerator nextObject])) {
			//
			// if an object / array is found
			// recursively scans the new Object
			// and create a <obj o=""></obj> TAG
			//
			// o = object name
			//
			if ([o isKindOfClass:[NSDictionary class]] || [o isKindOfClass:[NSArray class]]) {
				[self obj2xml:o trgObj:trgObj depth:depth + 1 objName:[NSString stringWithFormat:@"%ld", i]];
				
				if (_debug) {
					*trgObj = [*trgObj stringByPaddingToLength:[*trgObj length] + depth + 1 withString:@"\t" startingAtIndex:0];
				}
				
				*trgObj = [*trgObj stringByAppendingFormat:@"</obj>%@", _eof];
			}
			else {
				[self arrayAndObjectHelper:srcObj trgObj:trgObj depth:depth objName:objName varName:[NSString stringWithFormat:@"%ld", i] varValue:o];
			}
			
			i++;
		}		
	}
	
	// Close root TAG
	if (depth == 0) {
		*trgObj = [*trgObj stringByAppendingFormat:@"</dataObj>%@", _eof];
	}
}

+ (void)xml2obj:(CXMLElement *)x resObj:(id *)o
{
	for (CXMLElement *node in [x children]) {
		NSString *nodeName = [node name];
		
		// Handle Object
		if ([nodeName isEqualToString:@"obj"]) {
			NSString *objName = [[[node nodesForXPath:@"./@o" error:&error] objectAtIndex:0] stringValue];
			NSString *objType = [[[node nodesForXPath:@"./@t" error:&error] objectAtIndex:0] stringValue];
			
			id newObj = [NSNull null];
			
			// Create nested array				
			if ([objType isEqualToString:@"a"]) {
//				newObj = [NSMutableArray array];
				newObj = [NSMutableDictionary dictionary];
			}
			// Create nested object
			else if ([objType isEqualToString:@"o"]) {
				newObj = [NSMutableDictionary dictionary];
			}
				
//			if ([*o isKindOfClass:[NSDictionary class]]) {
				[*o setObject:newObj forKey:objName];
//			}
//			else {
//				[*o addObject:newObj];
//			}
				
			[self xml2obj:node resObj:&newObj];
		}
		else if ([nodeName isEqualToString:@"var"]) {
			NSString *varName = [[[node nodesForXPath:@"./@n" error:&error] objectAtIndex:0] stringValue];
			NSString *varType = [[[node nodesForXPath:@"./@t" error:&error] objectAtIndex:0] stringValue];
			NSString *varVal = [[[node nodesForXPath:@"." error:&error] objectAtIndex:0] stringValue];
			
			id varValue = @"";
			
			if ([varType isEqualToString:@"b"]) {
				varValue = [NSNumber numberWithBool:[varVal boolValue]];
			}
			else if ([varType isEqualToString:@"n"]) {
				varValue = [NSNumber numberWithInteger:[varVal integerValue]];
			}
			else if ([varType isEqualToString:@"s"]) {
				if (varVal != nil) {
					varValue = varVal;
				}
				else {
					varValue = @"";
				}
 			}
			else if ([varType isEqualToString:@"x"]) {
				varValue = [NSNull null];
			}
				
//			if ([*o isKindOfClass:[NSDictionary class]]) {
				[*o setObject:varValue forKey:varName];
//			}
//			else {
//				[*o addObject:varValue];
//			}
		}
	}
}


+ (NSString *)serialize:(NSDictionary *)o
{
	NSString *result = [NSString string];
	
	[self obj2xml:o trgObj:&result depth:0 objName:@""];
	
	return result;
}

+ (NSDictionary *)deserialize:(NSString *)xmlString
{
	NSMutableDictionary *resObj = [NSMutableDictionary dictionary];
	
	CXMLDocument *doc;
	
	doc = [[CXMLDocument alloc] initWithXMLString:xmlString options:0 error:&error];
	
	CXMLElement *xmlData = [[doc nodesForXPath:@"./dataObj" error:&error] objectAtIndex:0];
	
	[self xml2obj:xmlData resObj:&resObj];
	
	[doc release];
	
	return resObj;
}

@end