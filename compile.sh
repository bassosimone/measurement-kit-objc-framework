#!/bin/sh -e

# XXX: Currently this works on my system only

clang++ -std=c++11 -fobjc-arc -Wall -I $HOME/src/measurement-kit/measurement-kit-app-ios/Libight_iOS/Libight_iOS/include/ -I /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk/System/Library/Frameworks/Foundation.framework/ -c MeasurementKit/MeasurementKit.mm

clang++ -fobjc-arc -Wall -c main.m

clang++ -fobjc-arc -o main main.o MeasurementKit.o $HOME/src/measurement-kit/measurement-kit-app-ios/Libight_iOS/Libight_iOS/lib/*.a -L /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk/System/Library/Frameworks/Foundation.framework/ -framework Foundation

