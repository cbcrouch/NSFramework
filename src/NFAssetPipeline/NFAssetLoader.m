//
//  NFAssetLoader.m
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//

#import "NFAssetLoader.h"

#import "NFAssetData+Procedural.h"
#import "NFAssetData+Wavefront.h"

#import "NFUtils.h"


@implementation NFAssetLoader

+ (NFAssetData *) allocAssetDataOfType:(ASSET_TYPE)type withArgs:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION {

    NFAssetData *asset = [[NFAssetData alloc] init];

    //
    // TODO: is it common convention that variadic method arguments be of all
    //       the same type in Objective C
    //
/*
    if (firstObj != nil) {
        va_list args;
        va_start(args, firstObj);

        id obj = firstObj;

        //NSString *fileNamePath = (NSString *)firstObj;
        //NSLog(@"allocAssetDataOfType first arg: %@", fileNamePath);

        do {
            //
            // perfrom operations on object
            //
        } while ( (obj = va_arg(args, id)) );
    }
*/

    switch (type) {
        case kWavefrontObj: {
            NSAssert(firstObj != nil, @"ERROR: expected a string for the file name and path, received nil");
            NSString *fileNamePath = (NSString *)firstObj;

            va_list args;
            va_start(args, firstObj);

            id obj = va_arg(args, id);
            if (obj) {
                //NSLog(@"allocAssetDataOfType second arg is present, should be a bundle");
            }

            NFWavefrontObj *wavefrontObj = [[[NFWavefrontObj alloc] init] autorelease];
            [wavefrontObj loadFileWithPath:fileNamePath];

            //
            // TODO: profile and optimize the file parsing
            //
            [wavefrontObj parseFile];

            //
            // TODO: only one Wavefront object is currently supported, will need to update
            //       when support has been added for multiple Wavefront objects
            //
            [asset setNumberOfSubsets:[[[wavefrontObj object] groups] count]];

            NSUInteger index = 0;
            for (WFGroup *group in [[wavefrontObj object] groups]) {
                [asset addSubsetWithIndices:[group faceStrArray] ofObject:[wavefrontObj object] atIndex:index];
                index++;
            }

            // loop through all values and convert them into NFLightingModel objects
            NSMutableArray *surfaceModels = [[[NSMutableArray alloc] init] autorelease];
            for (NSValue *value in [wavefrontObj materialsArray]) {
                PhongMaterial_t mat;
                [value getValue:&mat];

                NFSurfaceModel *surface = [[[NFSurfaceModel alloc] init] autorelease];

                surface.name = mat.name;
                surface.Ns = mat.Ns;
                surface.Ni = mat.Ni;
                surface.Tr = mat.Tr;
                surface.Tf = convertCfloatArrayToNS(mat.Tf);
                surface.illum = mat.illum;
                surface.Ka = convertCfloatArrayToNS(mat.Ka);
                surface.Kd = convertCfloatArrayToNS(mat.Kd);
                surface.Ks = convertCfloatArrayToNS(mat.Ks);
                surface.Ke = convertCfloatArrayToNS(mat.Ke);
                surface.map_Ka = mat.map_Ka;
                surface.map_Kd = mat.map_Kd;
                surface.map_Ks = mat.map_Ks;
                surface.map_Ns = mat.map_Ns;

                // not yet implemented
                //surface.map_Tr = mat.map_Tr;
                //surface.map_bump = mat.map_bump;
                //surface.map_disp = mat.map_disp;
                //surface.map_decalT = mat.map_decalT;

                [surfaceModels addObject:surface];
            }

            [asset setSurfaceModelArray:surfaceModels];

            NFSurfaceModel * (^findSurfaceModel)(NSString *) = ^ NFSurfaceModel * (NSString *name) {
                for (NFSurfaceModel *surface in [asset surfaceModelArray]) {
                    if (surface.name == name) {
                        return surface;
                    }
                }
                return nil;
            };

            NSInteger subsetIndex = 0;
            for (WFGroup *group in [[wavefrontObj object] groups]) {
                // NOTE: subsets are 1-1 with the groups, this code will need to be udpated
                //       when support for multiple objects is added
                NFSubset *subset = [[asset subsetArray] objectAtIndex:subsetIndex];
                subset.surfaceModel = findSurfaceModel([group materialName]);
                subsetIndex++;
            }
        }
        break;

        case kSolidPlane: {
            [asset createPlaneOfSize:4];
            // NOTE: default draw mode should work

            NFSurfaceModel *surface = [NFSurfaceModel defaultModel];

            NSMutableArray *surfaceModels = [[[NSMutableArray alloc] init] autorelease];
            [surfaceModels addObject:surface];

            asset.surfaceModelArray = surfaceModels;

            for (NFSubset *subset in [asset subsetArray]) {
                subset.surfaceModel = [surfaceModels objectAtIndex:0];
            }
        }
        break;

        case kGridWireframe: {
            [asset createGridOfSize:4];
            for (NFSubset *subset in [asset subsetArray]) {
                [subset setDrawMode:kDrawLines];
            }

            NFSurfaceModel *surface = [NFSurfaceModel defaultModel];

            NSMutableArray *surfaceModels = [[[NSMutableArray alloc] init] autorelease];
            [surfaceModels addObject:surface];

            asset.surfaceModelArray = surfaceModels;

            for (NFSubset *subset in [asset subsetArray]) {
                subset.surfaceModel = [surfaceModels objectAtIndex:0];
            }
        }
        break;

        case kAxisWireframe:
            [asset createAxisOfSize:10];
            for (NFSubset *subset in [asset subsetArray]) {
                [subset setDrawMode:kDrawLines];
            }

            //
            // TODO: the loadAxisSurface requires a default model, need to ensure that it
            //       only gets a default model or implement this in a less hack-y manner
            //
            NFSurfaceModel *surface = [NFSurfaceModel defaultModel];
            [asset loadAxisSurface:surface];

            NSMutableArray *surfaceModels = [[[NSMutableArray alloc] init] autorelease];
            [surfaceModels addObject:surface];

            asset.surfaceModelArray = surfaceModels;

            for (NFSubset *subset in [asset subsetArray]) {
                subset.surfaceModel = [surfaceModels objectAtIndex:0];
            }
        break;

        default:
            NSAssert(false, @"ERROR: received unknown type for loading asset");
        break;
    }

    return asset;
}

@end
