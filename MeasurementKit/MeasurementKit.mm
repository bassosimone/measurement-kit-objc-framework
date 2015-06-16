/*-
 * This file is part of MeasurementKit <https://measurement-kit.github.io/>.
 *
 * MeasurementKit is free software. See AUTHORS and LICENSE for more
 * information on the copying conditions.
 */

#import "MeasurementKit.h"

#import <ight/common/settings.hpp>
#import <ight/common/poller.hpp>
#import <ight/ooni/dns_injection.hpp>

using namespace ight::common;
using namespace ight::ooni;

/*
 * Design: We use a global strict FIFO queue to run tests. We have the
 * disadvantage that tests cannot run concurrently. Yet, this makes code
 * simpler to understand, with less headaches related to the interplay
 * between C++ memory management and ARC.
 */

// XXX is it safe to initialize globals like this?
// Otherwise I can use the usual singleton pattern of C++
static dispatch_queue_t QUEUE = dispatch_queue_create("MeasurementKit", 0);
static MKTOnTestCompleteBlock TEST_COMPLETE = ^(MKTNetworkTest *t) {};

void MKTOnTestComplete(MKTOnTestCompleteBlock block) {
  TEST_COMPLETE = block;
}

@implementation MKTNetworkTest
@end

@implementation MKTDNSInjection

@synthesize inputFile;
@synthesize nameServer;

- (id) init {
  self = [super init];
  if (self) {
    inputFile = @"";
    nameServer = @"";
  }
  return self;
}

- (void) run {
  // TODO: disallow running this test more than once
  dispatch_async(QUEUE, ^{
    /*
     * NOTE: The current object (`self`) is referenced by this block
     * and will not be garbage collected because ight_loop() is blocking
     * therefore we don't leave this block until the test is done.
     */
    settings::Settings settings{
      {"nameserver", [nameServer UTF8String]}
    };
    dns_injection::DNSInjection test([inputFile UTF8String], settings);
    test.set_log_verbose(1);
    // TODO: Add function to receive the logging output
    test.begin([&test, self]() {
      test.end([&test, self]() {
        ight_break_loop();
      });
    });
    ight_loop();
    /*
     * Here to remind that we stay in the loop until the test is
     * complete, which keeps `self` referenced.
     */
    TEST_COMPLETE(self);
  });
}
@end
