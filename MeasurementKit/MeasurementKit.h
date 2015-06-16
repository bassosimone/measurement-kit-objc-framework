/*-
 * This file is part of MeasurementKit <https://measurement-kit.github.io/>.
 *
 * MeasurementKit is free software. See AUTHORS and LICENSE for more
 * information on the copying conditions.
 */

#import <Foundation/Foundation.h>

@interface MKTNetworkTest: NSObject
@end

@interface MKTDNSInjection : MKTNetworkTest
@property(copy) NSString *inputFile;
@property(copy) NSString *nameServer;
- (id) init;
- (void) run;
@end

typedef void (^MKTOnTestCompleteBlock)(MKTNetworkTest *);

#ifdef __cplusplus
extern "C" {
#endif

void MKTOnTestComplete(MKTOnTestCompleteBlock);

#ifdef __cplusplus
}
#endif
