#import <Foundation/Foundation.h>
#import <pthread.h>
#import "sqlite3.h"

@interface YMImageCache : NSObject {
	NSString *filename;
	NSInteger maxCount;
	
	sqlite3 *db;
	pthread_mutex_t lock;
}

- (id)initWithFile:(NSString *)path maxCount:(NSInteger)max;

- (NSString *)filename;

- (NSInteger)maxCount;

- (NSData *)fetch:(NSString *)url;

- (BOOL)push:(NSData *)data forKey:(NSString *)url;

- (BOOL)cleanUp;

@end
