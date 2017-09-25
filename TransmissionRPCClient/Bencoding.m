//
//  Bencoding.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 19.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "Bencoding.h"

#define UTF8_ACCEPT 0
#define UTF8_REJECT 1
#define ISDIGIT(c) ( ((c) >= '0' && (c) <= '9') )
#define DATA_ALWAYS_UTF8    0


static char *p, *p0;
static NSUInteger dataLength;

id decodeNextObject(void);  // forward declaration

static const uint8_t utf8d[] = {
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 00..1f
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 20..3f
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 40..5f
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 60..7f
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9, // 80..9f
    7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7, // a0..bf
    8,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2, // c0..df
    0xa,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x4,0x3,0x3, // e0..ef
    0xb,0x6,0x6,0x6,0x5,0x8,0x8,0x8,0x8,0x8,0x8,0x8,0x8,0x8,0x8,0x8, // f0..ff
    0x0,0x1,0x2,0x3,0x5,0x8,0x7,0x1,0x1,0x1,0x4,0x6,0x1,0x1,0x1,0x1, // s0..s0
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,0,1,0,1,1,1,1,1,1, // s1..s2
    1,2,1,1,1,1,1,2,1,2,1,1,1,1,1,1,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1, // s3..s4
    1,2,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1,1,1,1,1,1,3,1,3,1,1,1,1,1,1, // s5..s6
    1,3,1,1,1,1,1,3,1,3,1,1,1,1,1,1,1,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1, // s7..s8
};


BOOL isUTF8(char *str, int len)
{
    int type, state = UTF8_ACCEPT;
    
    for ( int i = 0; i < len; i++)
    {
        type = utf8d[(uint8_t)str[i]];
        state = utf8d[256 + state * 16 + type];
        
        if (state == UTF8_REJECT)
            break;
    }
    
    return state == UTF8_ACCEPT;
}


long long decodeInt()
{
    p0 = p;
    
    while ( *p != 'e' && *p != ':' ) p++;
    
    *p++ = '\0';
    
    return atoll(p0);
}

id  decodeData()
{
    // get data length
    int count = (int)decodeInt();
    
    // test data if it's a string
    if( isUTF8(p, count) )
    {
        p0 = p;
        p += count;
        char c = *p;
        *p = '\0';
        NSString *str = [NSString stringWithCString:p0 encoding: NSUTF8StringEncoding];
        *p = c;
        return str;
    }
    
    NSData *data = [NSData dataWithBytes:p length:count];
    p += count;
    
    return data;
}

NSString* decodeString()
{
    int count = (int)decodeInt();

    p0 = p;
    p += count;
    char c = *p;
    *p = '\0';
    NSString *str = [NSString stringWithCString:p0 encoding: NSUTF8StringEncoding];
    *p = c;
    return str;
}

NSArray* decodeArray()
{
    NSMutableArray *list = [NSMutableArray array];
    
    while ( *p != 'e' )
        [list addObject:decodeNextObject()];
   
    p++;
    return list;
}

NSDictionary *decodeDictionary()
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    while ( *p != 'e' )
        dict[ decodeString() ] = decodeNextObject();
    
    p++;
    return  dict;
}

id decodeNextObject()
{
    char c = *p++;
    
    if( c ==  'i' )
        return @(decodeInt());
    
    if( c == 'l' )
        return decodeArray();
            
    if( c == 'd' )
        return decodeDictionary();
            
    if( ISDIGIT(c) )
    {
        p--;
        return DATA_ALWAYS_UTF8 ? decodeString() : decodeData();
    }

    return nil;
}

id decodeObjectFromBencodedData(NSData *data)
{
    // alloc buffer for duplicated data
    dataLength = data.length;
    char *mp = malloc(dataLength);
    p = mp;
    
    [data getBytes:p length:dataLength];
    id obj = decodeNextObject();
    
    free(mp);
    return obj;
}
