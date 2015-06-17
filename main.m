#import "MeasurementKit/MeasurementKit.h"

static void init(MKTAsync *async) {
  MKTDNSInjection *test = [[MKTDNSInjection alloc] init];
  [test setInputFile:@"/tmp/hosts.txt"];
  [test setSettings:[NSMutableDictionary dictionaryWithDictionary:@{
    @"nameserver": @"8.8.8.8",
  }]];
  [test setOnLogLine:^(MKTNetworkTest *test, NSString *logLine) {
    NSLog(@"%@: %@", test, logLine);
  }];
  [async run:test];
  NSLog(@"%@: started", test);
}

int main() {
  MKTAsync *async = [[MKTAsync alloc] init];

  [async setOnTestComplete:^(MKTNetworkTest *test) {
    NSLog(@"%@: complete", test);
  }];

  [async setOnEmpty:^() {
    NSLog(@"No more pending tests");
  }];

  init(async);
  init(async);
  init(async);
  while (1) {
    init(async);
    sleep(1);
  }
}