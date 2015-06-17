#!/bin/sh -e

# XXX: Currently this works on my system only

clang++ -std=c++11 -fobjc-arc -Wall -I $HOME/src/measurement-kit/measurement-kit-app-ios/Libight_iOS/Libight_iOS/include/ -c MeasurementKit/MeasurementKit.mm

clang++ -fobjc-arc -Wall -c main.m

clang++ -fobjc-arc -o main main.o MeasurementKit.o $HOME/src/measurement-kit/measurement-kit-app-ios/Libight_iOS/Libight_iOS/lib/*.a -framework Foundation
