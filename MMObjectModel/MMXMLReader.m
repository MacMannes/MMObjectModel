//
//  MMXMLReader.m
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

#import "MMXMLReader.h"

@interface MMXMLReader (PRIVATE)

- (void)performInitialization;

@end

@implementation MMXMLReader 

- (id)initWithURL:(NSURL *)url
{
    if (self = [super init]) {
        [self performInitialization];
        
        _xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];        
        [_xmlParser setDelegate:self];
    }
    return self;
}

- (id)initWithData:(NSData *)data
{
    if (self = [super init]) {
        [self performInitialization];
        
        _xmlParser = [[NSXMLParser alloc] initWithData:data];        
        [_xmlParser setDelegate:self];
    }
    return self;
}


- (NSMutableDictionary *)convertToDictionary 
{
    if ([_xmlParser parse]) {
       return [_dictionaryStack objectAtIndex:0];
    }    
    
    return nil;
}

- (void)performInitialization
{
    _dictionaryStack = [[NSMutableArray alloc] init];
    _textInProgress = [[NSMutableString alloc] init];
    
    // Initialize the stack with a fresh dictionary
    [_dictionaryStack addObject:[NSMutableDictionary dictionary]];        

}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    // Save the current element name:
    _currentElementName = elementName;
    
    // Get the dictionary for the current level in the stack
    NSMutableDictionary *parentDict = [_dictionaryStack lastObject];
    
    // Create the child dictionary for the new element, and initilaize it with the attributes
    NSMutableDictionary *childDict = [NSMutableDictionary dictionary];
    [childDict addEntriesFromDictionary:attributeDict];
    
    // If there's already an item for this key, it means we need to create an array
    id existingValue = [parentDict objectForKey:elementName];
    if (existingValue) {
        NSMutableArray *array = nil;
        if ([existingValue isKindOfClass:[NSMutableArray class]]) {
            // The array exists, so use it
            array = (NSMutableArray *) existingValue;
        } else {
            // Create an array if it doesn't exist
            array = [NSMutableArray array];
            [array addObject:existingValue];
            
            // Replace the child dictionary with an array of children dictionaries
            [parentDict setObject:array forKey:elementName];
        }
        
        // Add the new child dictionary to the array
        [array addObject:childDict];
    } else {
        // No existing value, so update the dictionary
        [parentDict setObject:childDict forKey:elementName];
    }
    
    // Update the stack
    [_dictionaryStack addObject:childDict];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    // Update the parent dict with text info
    NSMutableDictionary *dictInProgress = [_dictionaryStack lastObject];
    
    // Set the text property
    if ([_textInProgress length] > 0 || [elementName isEqualToString:_currentElementName]) {
        // Pop the current dict
        [_dictionaryStack removeLastObject];
        dictInProgress = [_dictionaryStack lastObject];
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init]; 
        NSNumber *number = [numberFormatter numberFromString:_textInProgress]; 

        if (number) {
            [dictInProgress setObject:number forKey:elementName];
        }
        else {
            [dictInProgress setObject:_textInProgress forKey:elementName];
        }
        
        // Reset the text
        _textInProgress = nil;
        _textInProgress = [[NSMutableString alloc] init];
        return;
    }
    
    // Pop the current dict
    [_dictionaryStack removeLastObject];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    // Build the text value    
    NSString *newString = [string stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([newString length] > 0) {
        [_textInProgress appendString:string];
    }
    
}

@end
