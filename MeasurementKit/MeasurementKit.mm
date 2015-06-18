/*-
 * This file is part of MeasurementKit <https://measurement-kit.github.io/>.
 *
 * MeasurementKit is free software. See AUTHORS and LICENSE for more
 * information on the copying conditions.
 */

#import "MeasurementKit.h"

#import <ight/common/poller.hpp>
#import <ight/common/settings.hpp>

#import <ight/ooni/dns_injection.hpp>

using namespace ight::common::pointer;
using namespace ight::common::net_test;

using namespace ight::ooni::dns_injection;

//
// MKTNetworkTest
//

@implementation MKTNetworkTest
@synthesize inputFile = _inputFile;
@synthesize name = _name;
@synthesize settings = _settings;
@synthesize onLogLine = _onLogLine;

- (id)init {
    self = [super init];
    if (self) {
        _name = @"";
        _settings = [[NSMutableDictionary alloc] initWithCapacity:16];
        _inputFile = @"";
    }
    return self;
}

- (SharedPointer<NetTest>)makeShared {
    return SharedPointer<NetTest>{};
}
@end

//
// MKTDNSInjection
//

@implementation MKTDNSInjection
- (id)init {
    self = [super init];
    if (self) {
        [self setName:@"DNSInjection"];
    }
    return self;
}

- (SharedPointer<NetTest>)makeShared {
    NSString *nameserver = [[self settings] objectForKey:@"nameserver"];
    if (!nameserver)
        throw std::runtime_error("Invalid input");
    SharedPointer<NetTest> tp{new DNSInjection([[self inputFile] UTF8String], {
        {"nameserver", [nameserver UTF8String]},
    })};
    tp->set_log_verbose(1);
    tp->set_log_function([self](const char *s) {
        MKTOnLogLine func = [self onLogLine];
        if (func) {
            dispatch_async(dispatch_get_main_queue(), ^{
                /*
                 * XXX Here we pass `self` to the caller who may modify
                 * for example the logging function concurrently.
                 */
                func(self, [NSString stringWithUTF8String:s]);
            });
        }
    });
    return tp;
}
@end

//
// MKTRunner
//

@interface MKTRunnerState : NSObject {
  @public NSMutableDictionary *keepalive;
  @public dispatch_queue_t queue;
}
@end
@implementation MKTRunnerState
- (id)init {
    self = [super init];
    if (self) {
        keepalive = [[NSMutableDictionary alloc] initWithCapacity:16];
        queue = dispatch_queue_create("measurement-kit-serial-queue", 0);
    }
    return self;
}
@end

@implementation MKTRunner
@synthesize onTestComplete = _onTestComplete;
@synthesize onEmpty = _onEmpty;

- (id)init {
    self = [super init];
    if (self) {
        state = [[MKTRunnerState alloc] init];
    }
    return self;
}

- (void)runSerial:(MKTNetworkTest *)test {
    dispatch_async(state->queue, ^{
        SharedPointer<NetTest> tp = [test makeShared];
        NSNumber *number = [NSNumber numberWithLongLong:tp->identifier()];
        [state->keepalive setObject:test forKey:number];
        tp->begin([&tp]() { tp->end([]() { ight_break_loop(); }); });
        ight_loop();
        [state->keepalive removeObjectForKey:number];
        if (_onTestComplete) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _onTestComplete(test);
            });
        }
        if (_onEmpty) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _onEmpty();
            });
        };
    });
}
@end
