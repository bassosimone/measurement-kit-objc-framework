#import "MeasurementKit/MeasurementKit.h"

volatile int pending = 0;

static void runTest(MKTRunner *runner) {
    MKTDNSInjection *test = [[MKTDNSInjection alloc] init];
    [test setInputFile:@"/tmp/hosts.txt"];
    [test setSettings:[NSMutableDictionary dictionaryWithDictionary:@{
        @"nameserver" : @"8.8.8.8",
    }]];
    [test setOnLogLine:^(MKTNetworkTest *test, NSString *logLine) {
        NSLog(@"%@: %@", test, logLine);
    }];
    pending += 1;
    //[runner runParallel:test];  // <-- this crashes
    [runner runSerial:test];
    NSLog(@"%@: started", test);
}

int main() {
    MKTRunner *runner = [[MKTRunner alloc] init];

    [runner setOnTestComplete:^(MKTNetworkTest *test) {
        NSLog(@"%@: complete", test);
        pending -= 1;
    }];

    [runner setOnEmpty:^() {
        NSLog(@"No more pending tests");
    }];

    for (int i = 0; i < 16; ++i) {
        if (!pending) {
            runTest(runner);
            runTest(runner);
            runTest(runner);
        }
        sleep(1);
    }
}
