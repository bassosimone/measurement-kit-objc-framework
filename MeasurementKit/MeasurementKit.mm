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
@synthesize inputFile = _inputFile;
@synthesize name = _name;
@synthesize settings = _settings;
@synthesize onLogLine = _onLogLine;

- (id) init {
  self = [super init];
  if (self) {
    _name = @"";
    _settings = [[NSMutableDictionary alloc] initWithCapacity:16];
    _inputFile = @"";
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
  NSString *nameserver = [[self settings] objectForKey:@"nameserver"];
  if (!nameserver) throw std::runtime_error("Invalid input");
  SharedPointer<NetTest> tp{
    new DNSInjection([[self inputFile] UTF8String], {
      {"nameserver", [nameserver UTF8String]},
    })
  };
  tp->set_log_verbose(1);
  tp->set_log_function([self](const char *s) {
    MKTOnLogLine func = [self onLogLine];
    if (func) func(self, [NSString stringWithUTF8String:s]);
  });
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
@synthesize onTestComplete = _onTestComplete;
@synthesize onEmpty = _onEmpty;

- (id) init {
  self = [super init];
  if (self) {
    state = [[MKTAsyncState alloc] init];
    state->async.on_complete([self](SharedPointer<NetTest> tp) {
      NSNumber *number = [NSNumber numberWithLongLong:tp->identifier()];
      MKTNetworkTest *test = [state->keepalive objectForKey:number];
      [state->keepalive removeObjectForKey:number];
      if (_onTestComplete) _onTestComplete(test);
    });
    state->async.on_empty([self]() {
      if (_onEmpty) _onEmpty();
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
