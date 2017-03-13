//
//  DecodePolyline.h
//  hello map
//
//  Created by Meng Wang on 3/10/17.
//  Copyright © 2017 Meng Wang. All rights reserved.
//

#ifndef DecodePolyline_h
#define DecodePolyline_h

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface DecodePolyline : NSObject

+ (MKPolyline *)polylineWithEncodedString:(NSString *)encodedString;

@end
#endif /* DecodePolyline_h */
