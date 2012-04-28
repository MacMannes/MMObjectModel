//
//  MMObjectModel.h
//  MMObjectModel
//
//  Created by André Mathlener on 18-03-12.
//  Copyright (c) 2012 MacMannes. All rights reserved.

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Foundation/Foundation.h>

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#   define ELog(err) {if(err) DLog(@"%@", err)}
#else
#   define DLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);


/** This class is meant to be subclassed an can be used for mapping JSON or XML from restful API's to model classes.
 */

@interface MMObjectModel : NSObject {
    
}

/**-------------------------------------------------------------------------------------
 @name Initializing an 'MMObjectModel' Object
 ---------------------------------------------------------------------------------------
 */

/**
 creates and returns a `MMObjectModel` object initialized using the provided dictionary
 
 @param dictionary A dictionary.
 @returns A `MMObjectModel` object 
 @see initWithJSONData:
 */
- (id)initWithDictionary:(NSMutableDictionary *)dictionary;

/**
 creates and returns a `MMObjectModel` object initialized using the provided JSON data object
 
 @param jsonData An 'NSData' object containing JSON.
 @returns A `MMObjectModel` object 
 @see initWithDictionary:
 */
- (id)initWithJSONData:(NSData *)jsonData;

/**
 Returns a dictionary presentation of this object.
 */
- (NSDictionary *)dictionary;

/**-------------------------------------------------------------------------------------
 @name Serialization methods
 ---------------------------------------------------------------------------------------
 */

/**
 Returns JSON data in compact format (without spaces and indents).
 */
- (NSData *)jsonData;

/**
 Returns an JSON data in prettyfied format.
 */
- (NSData *)prettyJsonData;

/**
 Returns a JSON string in compact format (without spaces and indents).
 */
- (NSString *)jsonString;

/**
 Returns a JSON string in prettyfied format.
 */
- (NSString *)prettyJsonString;

/**-------------------------------------------------------------------------------------
 @name Other methods
 ---------------------------------------------------------------------------------------
 */

/**
 Returns an array with all property of this class.
 */
- (NSArray *)allKeys;

@end