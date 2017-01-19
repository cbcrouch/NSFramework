//
//  NFAssetWriter.h
//  NSFramework
//
//  Copyright © 2017 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NFCommonTypes.h"
#import "NFAssetData.h"

//
// NOTE: Wavefront obj vertices are stored in a right-handed coordinate system
//       (currently using right-handed coordinate system already)
//

@interface NFAssetWriter : NSObject

//
// TODO: add ability to write NFAssetData out to different file formats (Wavefront object files to start)
//
typedef NS_ENUM(NSUInteger, ASSET_FORMAT) {
    kWavefrontObjFormat
};

+ (void) writeAsset:(NFAssetData *)assetData toFile:(NSString *)filePath withFormat:(ASSET_FORMAT)format;

@end
