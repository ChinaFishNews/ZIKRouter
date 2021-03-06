//
//  AService.h
//  ZIKRouterTests
//
//  Created by zuik on 2018/4/18.
//  Copyright © 2018 zuik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AServiceInput.h"
#import "EasyServiceInput.h"

@interface AService : NSObject <AServiceInput, EasyServiceInput>

@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, strong) id router;
@end
