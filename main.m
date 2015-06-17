#import "MeasurementKit/MeasurementKit.h"

static volatile int again = 1;

static void init(MKTAsync *async) {
  MKTDNSInjection *test = [[MKTDNSInjection alloc] init];
  [test setInputFile:@"/tmp/hosts.txt"];
  [test setSettings:[NSMutableDictionary dictionaryWithDictionary:@{
    @"nameserver": @"8.8.8.8",
  }]];
  [async run:test];
  NSLog(@"Test started: %@", test);
}

int main() {
  MKTAsync *async = [[MKTAsync alloc] init];

  [async setOnTestComplete:^(MKTNetworkTest *test) {
    NSLog(@"Test complete: %@", test);
  }];

  [async setOnEmpty:^() {
    NSLog(@"No more pending tests");
    again = 0;
  }];

  init(async);
  init(async);
  init(async);

  while (again) sleep(1);
}
