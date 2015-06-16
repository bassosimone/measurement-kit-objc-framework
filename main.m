#import "MeasurementKit/MeasurementKit.h"

static volatile int running = 0;

static void init() {
  MKTDNSInjection *test = [[MKTDNSInjection alloc] init];
  [test setInputFile:@"/tmp/hosts.txt"];
  [test setNameServer:@"8.8.8.8"];
  [test run];
  running += 1;
}

int main() {

  MKTOnTestComplete(^(MKTNetworkTest *test) {
    NSLog(@"*** Test complete: %@", test);
    running -= 1;
  });

  init();
  init();
  init();

  while (running > 0) sleep(1);
}
