//
//  Bencoding.h
//
//  Bencode decoding functions
//

#import <Foundation/Foundation.h>


// decode and return BENCOD'ed data
id decodeObjectFromBencodedData(NSData *data);