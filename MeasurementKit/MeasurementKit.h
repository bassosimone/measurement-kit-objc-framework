/*-
 * This file is part of MeasurementKit <https://measurement-kit.github.io/>.
 *
 * MeasurementKit is free software. See AUTHORS and LICENSE for more
 * information on the copying conditions.
 */

#import <Foundation/Foundation.h>

//
// Network tests
//

@class MKTNetworkTest;

typedef void (^MKTOnLogLine)(MKTNetworkTest *, NSString *);

@interface MKTNetworkTest: NSObject
@property(atomic, readwrite, retain) NSString *name;
@property(atomic, readwrite, retain) NSMutableDictionary *settings;
@property(atomic, readwrite, retain) NSString *inputFile;
@property(atomic, readwrite, copy) MKTOnLogLine onLogLine;
- (id) init;
@end

@interface MKTDNSInjection : MKTNetworkTest
- (id) init;
@end

//
// Async
//

typedef void (^MKTOnTestComplete)(MKTNetworkTest *);
typedef void (^MKTOnEmpty)(void);

@class MKTAsyncState;

@interface MKTAsync : NSObject {
  MKTAsyncState *state;
}
@property(atomic, readwrite, copy) MKTOnTestComplete onTestComplete;
@property(atomic, readwrite, copy) MKTOnEmpty onEmpty;
- (id) init;
- (void) run:(MKTNetworkTest *)test;
@end
