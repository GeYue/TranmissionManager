//
//  ExtSCGifImageView.m
//  TransmissionManager
//
//  Created by 葛岳 on 16/8/14.
//  Copyright © 2016年 葛岳. All rights reserved.
//

#import "ExtSCGifImageView.h"

#import <ImageIO/ImageIO.h>

@implementation ExtSCGifImageFrame

@end

@interface ExtSCGifImageView()

- (void) resetTimer;

- (void) showNextImage;

@end

@implementation ExtSCGifImageView

- (void) resetTimer {
    if (self.timer && [self.timer isValid]) {
        [self.timer invalidate];
    }
    self.timer = nil;
}

- (void) setData:(NSData *)imageData {
    if (!imageData)
        return;
    [self resetTimer];
    
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
    size_t count = CGImageSourceGetCount(source);
    NSMutableArray * tmpArray = [NSMutableArray array];
    
    for (size_t i=0; i<count; i++) {
        ExtSCGifImageFrame * gifImage = [[ExtSCGifImageFrame alloc] init];
        CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
        gifImage.image = [UIImage imageWithCGImage:image
                                             scale:[UIScreen mainScreen].scale
                                       orientation:UIImageOrientationUp];
        NSDictionary * frameProperties = (__bridge_transfer NSDictionary *)CGImageSourceCopyPropertiesAtIndex(source, i, NULL);
        gifImage.duration = [[[frameProperties objectForKey:(NSString *)kCGImagePropertyGIFDictionary]
                              objectForKey:(NSString *)kCGImagePropertyGIFDelayTime] doubleValue];
        gifImage.duration = MAX(gifImage.duration, 0.01);
        
        [tmpArray addObject:gifImage];
        CGImageRelease(image);
    };
    CFRelease(source);
    
    self.imageFrameArray = nil;
    if (tmpArray.count > 1) {
        self.imageFrameArray = tmpArray;
        currentImageIndex = -1;
        _animating = YES;
        [self showNextImage];
    } else {
        self.image = [UIImage imageWithData:imageData];
    }
}

- (void) setImage:(UIImage *)image {
    [super setImage:image];
    [self resetTimer];
    self.imageFrameArray = nil;
    _animating = NO;
}

- (void) showNextImage {
    if (!_animating)
        return;
    
    currentImageIndex = (++currentImageIndex) % self.imageFrameArray.count;
    ExtSCGifImageFrame * gifImage = [self.imageFrameArray objectAtIndex:currentImageIndex];
    [super setImage:gifImage.image];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:gifImage.duration target:self
                                                selector:@selector(showNextImage) userInfo:nil repeats:NO];
}

- (void) setAnimating:(BOOL)animating {
    if (self.imageFrameArray.count < 2) {
        _animating = animating;
        return;
    }
    
    if (!_animating && animating) {
        //Continue
        _animating = animating;
        if (!_timer) {
            [self showNextImage];
        }
    } else if (_animating && !animating) {
        //Stop
        _animating = animating;
        [self resetTimer];
    }
}

@end

