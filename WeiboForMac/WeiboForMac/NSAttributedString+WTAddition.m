//
//  TUIAttributedString+WTAddition.m
//  WeiboForMac
//
//  Created by Wu Tian on 11-8-7.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "NSAttributedString+WTAddition.h"

@implementation NSAttributedString (WTAddition)

// Returns an HTTP URL delimiting character set
- (NSCharacterSet *) httpDelimitingCharset {
    NSCharacterSet * charset = [NSCharacterSet characterSetWithCharactersInString:@"±§$^*(){}[];'\"\\|,，<>`ÅÍÎÏ¡™£¢∞§¶•ªº≠œ∑´®†¥¨ˆøπ“‘åß∂ƒ©˙∆˚¬…æ«ÓÔ˘¿Â¯Ω≈ç√∫˜µ≤≥÷€‹›ﬁﬂ‡°·—Œ„´‰ˇÁ¨ˆØ∏”’˝ÒÚÆ»¸˛Ç◊ı˜!【】 ："];
	return charset;
}


// Returns a delimiting character set for twitter usernames and mailto: urls
- (NSCharacterSet *) usernameDelimitingCharset {
	NSCharacterSet * charset = [NSCharacterSet characterSetWithCharactersInString:@"±§!#$%^&*()+={}[];::：'\"\\|,./<>?`~ÅÍÎÏ¡™£¢∞§¶•ªº–≠œ∑´®†¥¨ˆøπ“‘åß∂ƒ©˙∆˚¬…æ«ÓÔΩ≈ç√∫˜µ≤≥÷⁄€‹›ﬁﬂ‡°·—Œ„´‰ˇÁ¨ˆØ∏”’˝ÒÚÆ»¸˛Ç◊ı˜Â¯˘¿）（）！——？。，【】、:"];
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

- (NSArray *) activeRanges {
	NSScanner *scanner;
	NSRange scanRange;
	NSString *scanString;
	NSCharacterSet *terminalCharacterSet;
	NSURL *foundURL;
	NSString *foundURLString, *username;
    NSString *hashtag;
	scanner = [NSScanner scannerWithString:[self string]];
	terminalCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    NSMutableArray * activeArray = [[NSMutableArray alloc] init];
	
	while (![scanner isAtEnd]) {
		[scanner scanUpToCharactersFromSet:terminalCharacterSet
								intoString:&scanString];
		scanRange.length = [scanString length];
		scanRange.location = [scanner scanLocation] - scanRange.length;
		
		// URLs
		if ((foundURLString = [self detectURL:scanString])) {
			NSRange prefixRange = [foundURLString rangeOfString:@"http://"];
			NSRange wwwRange = [foundURLString rangeOfString:@"www."];
			if (prefixRange.location == NSNotFound && 
                wwwRange.location == 0) {
				foundURL = [NSURL URLWithString:[NSString 
                                                 stringWithFormat:@"http://%@", foundURLString]];
			} else {
				foundURL = [NSURL URLWithString:foundURLString];
			}
			NSRange newRange = [scanString rangeOfString:foundURLString];
			NSRange attrRange;
			attrRange.location = scanRange.location + newRange.location;
			attrRange.length = newRange.length;
            ABFlavoredRange * link = [[ABFlavoredRange alloc] init];
            link.rangeValue = attrRange;
            link.displayString = [foundURL absoluteString];
            link.rangeFlavor = ABActiveTextRangeFlavorURL;
            [activeArray addObject:link];
            [link release];
		}
        
		// Twitter usernames
		if ((username = [self detectUsername:scanString])) {
            
			NSRange newRange = [scanString rangeOfString:username];
			NSRange attrRange;
			attrRange.location = scanRange.location + newRange.location;
			attrRange.length = newRange.length;
            ABFlavoredRange * name = [[ABFlavoredRange alloc] init];
            name.rangeValue = attrRange;
            name.displayString = [username substringFromIndex:1];
            name.rangeFlavor = ABActiveTextRangeFlavorTwitterUsername;
            [activeArray addObject:name];
            [name release];
            
		}
		
        
        // Hashtags
		if ((hashtag = [self detectHashtag:scanString])) {
			if ([hashtag length] > 1) {
				NSRange newRange = [scanString rangeOfString:hashtag];
				NSRange attrRange;
				attrRange.location = scanRange.location + newRange.location;
				attrRange.length = newRange.length;
				ABFlavoredRange * name = [[ABFlavoredRange alloc] init];
                name.rangeValue = attrRange;
                name.displayString = [hashtag substringWithRange:NSMakeRange(1, [hashtag length]-2)];
                name.rangeFlavor = ABActiveTextRangeFlavorTwitterHashtag;
                [activeArray addObject:name];
                [name release];
			}
		}
         
        
	}
    return [activeArray autorelease];
}


@end
