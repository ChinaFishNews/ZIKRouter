//
//  ZIKInfoViewRouter.m
//  ZIKRouterDemo
//
//  Created by zuik on 2017/7/5.
//  Copyright © 2017 zuik. All rights reserved.
//

#import "ZIKInfoViewRouter.h"
#import "ZIKInfoViewController.h"
@import ZIKRouter.Internal;
#import "AppRouteRegistry.h"

id<EasyInfoViewProtocol1> makeDestiantionForInfoViewProtocol(ZIKViewRouteConfiguration *configuration) {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ZIKInfoViewController *destination = [sb instantiateViewControllerWithIdentifier:@"info"];
    destination.title = @"info";
    return destination;
}

// Let ZIKViewMakeableConfiguration conform to EasyInfoViewModuleProtocol
DeclareRoutableViewModuleProtocol(EasyInfoViewModuleProtocol)

@interface ZIKInfoViewController (ZIKInfoViewRouter) <ZIKRoutableView>
@end
@implementation ZIKInfoViewController (ZIKInfoViewRouter)
@end

@implementation ZIKInfoViewRouter

+ (void)registerRoutableDestination {
    
#if TEST_BLOCK_ROUTES
    [ZIKDestinationViewRoute(id<ZIKInfoViewProtocol>) makeRouteWithDestination:[ZIKInfoViewController class] makeDestination:^id<ZIKInfoViewProtocol> _Nullable(ZIKViewRouteConfig * _Nonnull config, __kindof ZIKRouter<id<ZIKInfoViewProtocol>,ZIKViewRouteConfig *,ZIKViewRemoveConfiguration *> * _Nonnull router) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ZIKInfoViewController *destination = [sb instantiateViewControllerWithIdentifier:@"info"];
        destination.title = @"info";
        return destination;
    }]
    .registerDestinationProtocol(ZIKRoutable(ZIKInfoViewProtocol))
    .registerURLPattern(@"router://info")
    .destinationFromExternalPrepared(^BOOL(id<ZIKInfoViewProtocol> destination, ZIKViewRouter * _Nonnull router) {
        if (destination.name.length > 0 && destination.age > 0) {
            return YES;
        }
        return NO;
    });
#else
    [self registerViewProtocol:ZIKRoutable(ZIKInfoViewProtocol)];
    [self registerURLPattern:@"router://info"];
#endif
    
    [self registerView:[ZIKInfoViewController class]];
    
    // Test easy factory
    [ZIKDestinationViewRouter(id<EasyInfoViewProtocol1>)
     registerViewProtocol:ZIKRoutable(EasyInfoViewProtocol1)
     forMakingView:[ZIKInfoViewController class]
     factory:makeDestiantionForInfoViewProtocol];
    
    [ZIKDestinationViewRouter(id<EasyInfoViewProtocol2>)
     registerViewProtocol:ZIKRoutable(EasyInfoViewProtocol2)
     forMakingView:[ZIKInfoViewController class]
     making:^id<EasyInfoViewProtocol2> _Nullable(ZIKViewRouteConfig * _Nonnull config) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ZIKInfoViewController *destination = [sb instantiateViewControllerWithIdentifier:@"info"];
        destination.title = @"info";
        return destination;
    }];
    
    // Test module config factory
    [ZIKModuleViewRouter(EasyInfoViewModuleProtocol)
     registerModuleProtocol:ZIKRoutable(EasyInfoViewModuleProtocol)
     forMakingView:[ZIKInfoViewController class]
     making:^ZIKViewRouteConfiguration<ZIKConfigurationMakeable> * _Nonnull{
         ZIKViewMakeableConfiguration<id<ZIKInfoViewProtocol>><EasyInfoViewModuleProtocol> *config = [ZIKViewMakeableConfiguration new];
         __weak typeof(config) weakConfig = config;
         
         config._prepareDestination = ^(id<ZIKInfoViewProtocol>  _Nonnull destination) {
             NSLog(@"_prepareDestination: %@", destination);
         };
         
         // User is responsible for calling makeDestinationWith and giving parameters
         config.makeDestinationWith = ^id(NSString *title, NSInteger age, __weak _Nullable id<ZIKInfoViewDelegate> delegate) {
             weakConfig.makeDestination = ^ZIKInfoViewController * _Nullable{
                 UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                 ZIKInfoViewController *destination = [sb instantiateViewControllerWithIdentifier:@"info"];
                 destination.title = @"info";
                 destination.name = title;
                 destination.age = age;
                 destination.delegate = delegate;
                 return destination;
             };
             weakConfig.makedDestination = weakConfig.makeDestination();
             return weakConfig.makedDestination;
         };
         
         // User is responsible for calling constructDestination and giving parameters
         config.constructDestination = ^(NSString *title, NSInteger age, __weak _Nullable id<ZIKInfoViewDelegate> delegate) {
             // Capture parameters in makeDestination, so we don't need configuration subclass to hold the parameters
             // MakeDestination will be used for creating destination instance
             // didMakeDestination will be auto called after creating destination
             weakConfig.makeDestination = ^ZIKInfoViewController * _Nullable{
                 UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                 ZIKInfoViewController *destination = [sb instantiateViewControllerWithIdentifier:@"info"];
                 destination.title = @"info";
                 destination.name = title;
                 destination.age = age;
                 destination.delegate = delegate;
                 return destination;
             };
         };
         return config;
    }];
}

- (id<ZIKInfoViewProtocol>)destinationWithConfiguration:(ZIKViewRouteConfiguration *)configuration {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ZIKInfoViewController *destination = [sb instantiateViewControllerWithIdentifier:@"info"];
    destination.title = @"info";
    return destination;
}

- (BOOL)destinationFromExternalPrepared:(UIViewController<ZIKInfoViewProtocol> *)destination {
    NSParameterAssert([destination isKindOfClass:[ZIKInfoViewController class]]);
    if (destination.name.length > 0 && destination.age > 0) {
        return YES;
    }
    return NO;
}

- (void)didFinishPrepareDestination:(id)destination configuration:(__kindof ZIKViewRouteConfiguration *)configuration {
    
}

+ (void)router:(nullable ZIKViewRouter *)router willPerformRouteOnDestination:(id)destination fromSource:(id)source {
    NSLog(@"\n----------------------\nrouter: (%@),\n\
          ➡️ will\n\
          perform route\n\
          from source: (%@),\n\
          destination: (%@),\n----------------------",router, source, destination);
}

+ (void)router:(nullable ZIKViewRouter *)router didPerformRouteOnDestination:(id)destination fromSource:(id)source {
    NSLog(@"\n----------------------\nrouter: (%@),\n\
          ✅ did\n\
          perform route\n\
          from source: (%@),\n\
          destination: (%@),\n----------------------",router, source, destination);
}

+ (void)router:(nullable ZIKViewRouter *)router willRemoveRouteOnDestination:(id)destination fromSource:(id)source {
    NSLog(@"\n----------------------\nrouter: (%@),\n\
          ⬅️ will\n\
          remove route\n\
          from source: (%@),\n\
          destination: (%@),\n----------------------",router, source, destination);
}

+ (void)router:(nullable ZIKViewRouter *)router didRemoveRouteOnDestination:(id)destination fromSource:(id)source {
    NSLog(@"\n----------------------\nrouter: (%@),\n\
          ❎ did\n\
          remove route\n\
          from source: (%@),\n\
          destination: (%@),\n----------------------",router, source, destination);
}

@end
