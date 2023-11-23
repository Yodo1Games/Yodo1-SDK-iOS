//
//  BDAudioRecordLog.h
//  Pods
//
//  Created by Cliffe on 2022/1/30.
//

#ifndef BDAudioRecordLog_h
#define BDAudioRecordLog_h

#if defined(__cplusplus)
extern "C"
{
#endif

void BDAudioRecordLog(const char *_filename, const char *_func_name, NSString *_tag, int _level, int _line, NSString * _format);
typedef void (*BDAudioRecordLogCallback)(const char *_filename, const char *_func_name, NSString *_tag, int _level, int _line, NSString * _format);

void BDAudioRecordRegisterALogCallback(BDAudioRecordLogCallback callback);
void BDAudioRecordUnregisterALogCallback(BDAudioRecordLogCallback callback);

#if defined(__cplusplus)
}
#endif

#endif /* BDAudioRecordLog_h */
