//
//  MMXMLReader.h
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
//  THE SOFTWARE. Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Instances of this class parse XML documents and converts them to NSMutableDictionaries, so they can be handled as easy as parsed JSON objects.
 */

@interface MMXMLReader : NSObject <NSXMLParserDelegate> {
    NSXMLParser *_xmlParser;
    
    NSMutableArray *_dictionaryStack;
    NSMutableString *_textInProgress;    
}

/**-------------------------------------------------------------------------------------
 @name Initializing a Parser Object
 ---------------------------------------------------------------------------------------
 */

/**
 Initializes the receiver with the given URL.
 
 @param url The URL to the XML file.
 @returns An initialized `MMXMLreader` object or nil if an error occurs. 
 */
- (id)initWithURL:(NSURL *)url;

/**-------------------------------------------------------------------------------------
 @name Parsing
 ---------------------------------------------------------------------------------------
 */

/**
 Starts the parsing operation and returns an 'NSMutableDictionary' object if succesful.
 
 @returns An `NSMutableDictionary` object or nil if an error occurs. 
 */

- (NSMutableDictionary *)convertToDictionary;

@end
