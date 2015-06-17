#import "MeasurementKit/MeasurementKit.h"

static volatile int running = 0;

static void init(MKTAsync *async) {
  MKTDNSInjection *test = [[MKTDNSInjection alloc] init];
  [test setInputFile:@"/tmp/hosts.txt"];
  [test setSettings:[NSMutableDictionary dictionaryWithDictionary:@{
    @"nameserver": @"8.8.8.8",
  }]];
  [async run:test];
  running += 1;
  NSLog(@"Test started: %@", test);
}

int main() {
  MKTAsync *async = [[MKTAsync alloc] init];

  [async setOnTestComplete:^(MKTNetworkTest *test) {
    NSLog(@"Test complete: %@", test);
    running -= 1;
  }];

  init(async);
  init(async);
  init(async);

  while (running > 0) sleep(1);
}
