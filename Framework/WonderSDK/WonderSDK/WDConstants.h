//
//  WDConstants.h
//  WonderSDK
//
//  Created by Wonder on 14/12/16.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

/* System Version */
#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

/* Device Type */
#define IS_IPHONE           ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
#define IS_IPAD             ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)