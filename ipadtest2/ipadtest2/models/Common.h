//
//  Common.h
//  ipadtest2
//
//  Created by kench on 2018/6/15.
//  Copyright © 2018年 kench. All rights reserved.
//

#ifndef Common_h
#define Common_h

#define kenscreenwidth UIScreen.mainScreen.bounds.size.width

#define kenscreenheight UIScreen.mainScreen.bounds.size.height

#define kServiceUUID @"0000ffe0-0000-1000-8000-00805f9b34fb" //服务的UUID
#define kCharacteristicUUID @"0000ffe1-0000-1000-8000-00805f9b34fb" //特征的UUID


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]


#endif /* Common_h */
