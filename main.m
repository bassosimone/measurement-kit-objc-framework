#import "MeasurementKit/MeasurementKit.h"

volatile int pending = 0;

static void init(MKTRunner *async) {
  MKTDNSInjection *test = [[MKTDNSInjection alloc] init];
  [test setInputFile:@"/tmp/hosts.txt"];
  [test setSettings:[NSMutableDictionary dictionaryWithDictionary:@{
    @"nameserver": @"8.8.8.8",
  }]];
  [test setOnLogLine:^(MKTNetworkTest *test, NSString *logLine) {
    NSLog(@"%@: %@", test, logLine);
  }];
  pending += 1;
  //[async runParallel:test];  // <-- this crashes
  [async runSerial:test];
  NSLog(@"%@: started", test);
}

int main() {
  MKTRunner *async = [[MKTRunner alloc] init];

  [async setOnTestComplete:^(MKTNetworkTest *test) {
    NSLog(@"%@: complete", test);
    pending -= 1;
  }];

  [async setOnEmpty:^() {
    NSLog(@"No more pending tests");
  }];

  for (int i = 0; i < 16; ++i) {
    if (!pending) {
      init(async);
      init(async);
      init(async);
    }
    sleep(1);
  }
}
