/*-
 * This file is part of MeasurementKit <https://measurement-kit.github.io/>.
 *
 * MeasurementKit is free software. See AUTHORS and LICENSE for more
 * information on the copying conditions.
 */

#import "MeasurementKit.h"

#import <ight/common/async.hpp>
#import <ight/common/poller.hpp>
#import <ight/common/settings.hpp>

#import <ight/ooni/dns_injection.hpp>

using namespace ight::common::async;
using namespace ight::common::pointer;
using namespace ight::common::net_test;

using namespace ight::ooni::dns_injection;

//
// MKTNetworkTest
//

@implementation MKTNetworkTest
@synthesize inputFile;
@synthesize name;
@synthesize settings;

- (id) init {
  self = [super init];
  if (self) {
    name = @"";
    settings = [[NSMutableDictionary alloc] initWithCapacity:16];
    inputFile = @"";
  }
  return self;
}

- (SharedPointer<NetTest>) makeShared {
  return SharedPointer<NetTest>{};
}
@end

//
// MKTDNSInjection
//

@implementation MKTDNSInjection
- (id) init {
  self = [super init];
  if (self) {
    [self setName:@"DNSInjection"];
  }
  return self;
}

- (SharedPointer<NetTest>) makeShared {
  SharedPointer<NetTest> tp{
    // TODO: Use values set by user rather than hardcoded defaults
    new DNSInjection("/tmp/hosts.txt", {
      {"nameserver", "8.8.8.8"},
    })
  };
  tp->set_log_verbose(1);
  // TODO: Allow to register and use function to see logs
  return tp;
}
@end

//
// MKTAsync
//

@interface MKTAsyncState : NSObject {
  @public Async async;
  @public NSMutableDictionary *keepalive;
}
@end
@implementation MKTAsyncState
- (id) init {
  self = [super init];
  if (self) {
    keepalive = [[NSMutableDictionary alloc] initWithCapacity:16];
  }
  return self;
}
@end

@implementation MKTAsync
@synthesize onTestComplete;

- (id) init {
  self = [super init];
  if (self) {
    state = [[MKTAsyncState alloc] init];
    state->async.on_complete([self](SharedPointer<NetTest> tp) {
      NSNumber *number = [NSNumber numberWithLongLong:tp->identifier()];
      MKTNetworkTest *test = [state->keepalive objectForKey:number];
      [state->keepalive removeObjectForKey:number];
      if (onTestComplete) onTestComplete(test);
    });
  }
  return self;
}

- (void) run:(MKTNetworkTest *)test {
  SharedPointer<NetTest> tp = [test makeShared];
  NSNumber *number = [NSNumber numberWithLongLong:tp->identifier()];
  [state->keepalive setObject:test forKey:number];
  state->async.run_test(tp);
}
@end
