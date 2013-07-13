//
//  NSMutableAttributedString+ORSCanaryAdditions.m
//  Canary
//
//  Created by Nicholas Toumpelis on 12/04/2009.
//  Copyright 2008-2009 Ocean Road Software, Nick Toumpelis.
//
//  Version 0.7.1
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy 
//  of this software and associated documentation files (the "Software"), to 
//  deal in the Software without restriction, including without limitation the 
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
//  sell copies of the Software, and to permit persons to whom the Software is 
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in 
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
//  IN THE SOFTWARE.

#import "NSMutableAttributedString+ORSCanaryAdditions.h"
#import "ABActiveRange.h"

@implementation NSMutableAttributedString ( ORSCanaryAdditions )

// Returns an HTTP URL delimiting character set
- (NSCharacterSet *) httpDelimitingCharset {
    NSCharacterSet * charset = [NSCharacterSet characterSetWithCharactersInString:@"±§$^*(){}[];'\"\\|,，<>`ÅÍÎÏ¡™£¢∞§¶•ªº≠œ∑´®†¥¨ˆøπ“‘åß∂ƒ©˙∆˚¬…æ«ÓÔ˘¿Â¯Ω≈ç√∫˜µ≤≥÷€‹›ﬁﬂ‡°·—Œ„´‰ˇÁ¨ˆØ∏”’˝ÒÚÆ»¸˛Ç◊ı˜!【】 ："];
	return charset;
}


// Returns a delimiting character set for twitter usernames and mailto: urls
- (NSCharacterSet *) usernameDelimitingCharset {
	NSCharacterSet * charset = [NSCharacterSet characterSetWithCharactersInString:@"±§!#$%^&*()+={}[];:：'\"\\|,./<>?`~ÅÍÎÏ¡™£¢∞§¶•ªº–≠œ∑´®†¥¨ˆøπ“‘åß∂ƒ©˙∆˚¬…æ«ÓÔΩ≈ç√∫˜µ≤≥÷⁄€‹›ﬁﬂ‡°·—Œ„´‰ˇÁ¨ˆØ∏”’˝ÒÚÆ»¸˛Ç◊ı˜Â¯˘¿）（）！——？。，【】、"];
	return charset;
}

// Returns a delimiting character set for twitter hashtag
- (NSCharacterSet *) hashtagDelimitingCharset {
	NSCharacterSet * charset = [NSCharacterSet characterSetWithCharactersInString:@"#±§!$%^&*()+={}[];:'\"\\|,./<>?`~ÅÍÎÏ¡™£¢∞§¶•ªº–≠œ∑´®†¥¨ˆøπ“‘åß∂ƒ©˙∆˚¬…æ«ÓÔΩ≈ç√∫˜µ≤≥÷⁄€‹›ﬁﬂ‡°·—Œ„´‰ˇÁ¨ˆØ∏”’˝ÒÚÆ»¸˛Ç◊ı˜Â¯˘¿"];
	return charset;
}

// Detects all types of URLs (except special Twitter names)
- (NSString *) detectURL:(NSString *)string {	
	NSRange range;
	
	range = [string rangeOfString:@"www.."];
	if (range.location != NSNotFound) {
		return nil;
	}
	
	range = [string rangeOfString:@"http://"];
	if (range.location != NSNotFound) {
		NSString *substring = [string substringFromIndex:range.location];
		NSRange charsetRange = [substring 
			rangeOfCharacterFromSet:[self httpDelimitingCharset]];
		if (charsetRange.location == NSNotFound) {
			return substring;
		} else {
			return [substring substringToIndex:charsetRange.location];
		}
	}
	
	range = [string rangeOfString:@"https://"];
	if (range.location != NSNotFound) {
		NSString *substring = [string substringFromIndex:range.location];
		NSRange charsetRange = [substring 
						rangeOfCharacterFromSet:[self httpDelimitingCharset]];
		if (charsetRange.location == NSNotFound) {
			return substring;
		} else {
			return [substring substringToIndex:charsetRange.location];
		}
	}

	range = [string rangeOfString:@"www."];
	if (range.location == 0) {
		NSString *substring = [string substringFromIndex:range.location];
		NSRange charsetRange = [substring 
			rangeOfCharacterFromSet:[self httpDelimitingCharset]];
		if (charsetRange.location == NSNotFound) {
			if ([substring length] > 10) {
				return substring;
			}
		} else {
			if ([[substring substringToIndex:charsetRange.location] 
					length] > 10) {
				return [substring substringToIndex:charsetRange.location];
			}
		}
	}
	
	range = [string rangeOfString:@"mailto:"];
	if (range.location != NSNotFound) {
		NSString *substring = [string substringFromIndex:range.location];
		NSRange charsetRange = [substring 
			rangeOfCharacterFromSet:[self httpDelimitingCharset]];
		if (charsetRange.location == NSNotFound) {
			return substring;
		} else {
			return [substring substringToIndex:charsetRange.location];
		}
	}
	
	return nil;
}

// Detects usernames
- (NSString *) detectUsername:(NSString *)string {	
	NSRange range = [string rangeOfString:@"@"];
	if (range.location == NSNotFound) {
		return nil;
	} 
    else {
            NSString *substring = [string substringFromIndex:range.location];
			NSRange charsetRange = [substring 
				rangeOfCharacterFromSet:[self usernameDelimitingCharset]];
			if (charsetRange.location == NSNotFound) {
				return substring;
			} else {
				return [substring substringToIndex:charsetRange.location];
			}
	}
}

// Detects hashtags
- (NSString *) detectHashtag:(NSString *)string {
	NSRange range = [string rangeOfString:@"#"];
	if (range.location == NSNotFound) {
		return nil;
	} else {
        NSString *substring = [string substringFromIndex:range.location];
        NSString *substringWithoutFirstSharp = [substring substringFromIndex:1];
        NSRange endRange = [substringWithoutFirstSharp rangeOfString:@"#"];
        if (endRange.location == NSNotFound) {
            return nil;
        }
        else{
            endRange.location += 2;
            NSString * result = [substring substringToIndex:endRange.location];
            if ([result length] == 0) {
                return nil;
            }
            return result;
        }
    }
}




// Returns an attributed string for an emoticon
/*
- (NSAttributedString *) emoticonStringWithName:(NSString *)name {
	NSString *emoticonPath = [NSBundle pathForResource:name
												ofType:@"png"
										   inDirectory:@"./Canary.app"];
	NSFileWrapper *emoticon = [[NSFileWrapper alloc] 
							   initWithPath:emoticonPath];
	NSTextAttachment *emoticonAttachment = [[NSTextAttachment alloc] 
											initWithFileWrapper:emoticon];
	NSAttributedString *emoticonString = [NSAttributedString 
							attributedStringWithAttachment:emoticonAttachment];
	return emoticonString;
}
 */

// Highlights the detected elements in statuses (and enables actions on 
// clicking)
- (void) highlightElements {
	NSScanner *scanner;
	NSRange scanRange;
	NSString *scanString;
	NSCharacterSet *terminalCharacterSet;
	NSString *foundURLString, *username;
    NSString *hashtag;
	NSDictionary *linkAttr, *usernameAttr;
    NSDictionary *hashtagAttr;
	scanner = [NSScanner scannerWithString:[self string]];
	terminalCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    NSColor * highlightedColor = [NSColor 
                                  colorWithCalibratedRed:87.0/255.0 green:108.0/255.0 blue:121.0/255.0 alpha:1.0];
    NSColor * hashtagColor = [NSColor colorWithDeviceWhite:0.6 alpha:1.0];
	while (![scanner isAtEnd]) {
		[scanner scanUpToCharactersFromSet:terminalCharacterSet
								intoString:&scanString];
		scanRange.length = [scanString length];
		scanRange.location = [scanner scanLocation] - scanRange.length;
		
        
		// URLs
		if ((foundURLString = [self detectURL:scanString])) {
            
			linkAttr = [NSDictionary dictionaryWithObjectsAndKeys:
				highlightedColor, NSForegroundColorAttributeName,
							 NULL];
			NSRange newRange = [scanString rangeOfString:foundURLString];
			NSRange attrRange;
			attrRange.location = scanRange.location + newRange.location;
			attrRange.length = newRange.length;
			[self addAttributes:linkAttr range:attrRange];
             
		}
        
        
		// Twitter usernames
		if ((username = [self detectUsername:scanString])) {
			//NSMutableString *userLinkString = [NSMutableString stringWithString:@"weibomac://screen_name="];
            
			//[userLinkString appendString:[username substringFromIndex:1]];
			//foundURL = [NSURL URLWithString:[userLinkString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			
           // NSLog(@"foundURL:%@",foundURL);
            
            
            usernameAttr = [NSDictionary dictionaryWithObjectsAndKeys:
				highlightedColor, NSForegroundColorAttributeName, nil];
			NSRange newRange = [scanString rangeOfString:username];
			NSRange attrRange;
			attrRange.location = scanRange.location + newRange.location;
			attrRange.length = newRange.length;
			[self addAttributes:usernameAttr range:attrRange];
             
            //[self addAttribute:NSLinkAttributeName value:foundURL range:attrRange];
            //NSLog(@"username: %@",username);
            //NSLog(@"range   : %ld,%ld",attrRange.location , attrRange.length);
		}
		
        
		// Hashtags
		if ((hashtag = [self detectHashtag:scanString])) {
			if ([hashtag length] > 1) {
				hashtagAttr = [NSDictionary dictionaryWithObjectsAndKeys:
					hashtagColor, NSForegroundColorAttributeName, nil];
				NSRange newRange = [scanString rangeOfString:hashtag];
				NSRange attrRange;
				attrRange.location = scanRange.location + newRange.location;
				attrRange.length = newRange.length;
				[self addAttributes:hashtagAttr range:attrRange];
			}
		}
         
        
	}
}

@end
