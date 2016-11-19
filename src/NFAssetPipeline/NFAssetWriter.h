//
//  NFAssetWriter.h
//  NSFramework
//
//  Copyright © 2016 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NFCommonTypes.h"
#import "NFAssetData.h"

@interface NFAssetWriter : NSObject

//
// TODO: add ability to write NFAssetData out to different file formats (Wavefront object files to start)
//

typedef NS_ENUM(NSUInteger, ASSET_FORMAT) {
    kWavefrontObjFormat
};

+ (void) writeAsset:(NFAssetData *)assetData toFile:(NSString *)filePath withFormat:(ASSET_FORMAT)format;

@end
