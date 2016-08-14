//
//  ExtSCGifImageView.h
//  TransmissionManager
//
//  Created by 葛岳 on 16/8/14.
//  Copyright © 2016年 葛岳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExtSCGifImageFrame : NSObject

@property (nonatomic, assign) double duration;
@property (nonatomic, strong) UIImage * image;

@end

@interface ExtSCGifImageView : UIImageView {
    NSInteger currentImageIndex;
}

@property (nonatomic, strong) NSArray * imageFrameArray;
@property (nonatomic, strong) NSTimer * timer;

@property (nonatomic, assign) BOOL animating;

- (void) setData:(NSData *)imageData;

@end
