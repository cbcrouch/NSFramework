//
//  NFGTDataTypes.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

typedef struct { double red; double green; double blue; double alpha; } GTClearColor;

typedef struct { NSUInteger x; NSUInteger y; NSUInteger z; } GTOrigin;
typedef struct { NSUInteger width; NSUInteger height; NSUInteger depth; } GTSize;
typedef struct { GTOrigin origin; GTSize size; } GTRegion;

typedef struct { NSUInteger x; NSUInteger y; NSUInteger width; NSUInteger height; } GTScissorRect;

typedef struct { double originX; double originY; double width; double height; double znear; double zfar; } GTViewport;
