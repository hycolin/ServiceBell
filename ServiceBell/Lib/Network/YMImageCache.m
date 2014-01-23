#import "YMImageCache.h"

@implementation YMImageCache

- (id)init {
	[self release];
	return nil;
}

- (id)initWithFile:(NSString *)path maxCount:(NSInteger)max {
	if(self = [super init]) {
		db = NULL;
		if(sqlite3_libversion_number() < 3006012) {
			if(sqlite3_open([path UTF8String], &db) != SQLITE_OK) {
				sqlite3_close(db);
				[self release];
				return nil;
			}
		} else {
			if(sqlite3_open_v2([path UTF8String], &db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX, NULL) != SQLITE_OK) {
				sqlite3_close(db);
				[self release];
				return nil;
			}
		}
		const char *sql = "CREATE TABLE IF NOT EXISTS IMAGES (URL TEXT PRIMARY KEY, TIME INTEGER, SIZE INTEGER, DATA BOLB);";
		if(sqlite3_exec(db, sql, NULL, NULL, NULL) != SQLITE_OK) {
			sqlite3_close(db);
			[self release];
			return nil;
		}
		if(pthread_mutex_init(&lock, NULL)) {
			[self release];
			return nil;
		}
		filename = [path retain];
		maxCount = max;
	}
	return self;
}

- (NSString *)filename {
	return filename;
}

- (NSInteger)maxCount {
	return maxCount;
}

- (NSData *)fetch:(NSString *)url {
	NSString *sql = [NSString stringWithFormat:@"SELECT DATA, TIME FROM IMAGES WHERE URL = \"%@\";", url];
	if(pthread_mutex_lock(&lock))
		return nil;
	sqlite3_stmt *stmt = NULL;
	NSData *data = nil;
	NSInteger time = 0;
	if(sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
		if(SQLITE_ROW == sqlite3_step(stmt)) {
			data = [[NSData alloc] initWithBytes:sqlite3_column_blob(stmt, 0) length:sqlite3_column_bytes(stmt, 0)];
			time = sqlite3_column_int(stmt, 1);
		}
	}
	sqlite3_finalize(stmt);
	if(data) {
		NSDate *date = [[NSDate alloc] init];
		NSInteger timeNow = [date timeIntervalSince1970];
		[date release];
		if(timeNow - time > 30) {
			sql = [NSString stringWithFormat:@"UPDATE IMAGES SET TIME = %d WHERE URL = \"%@\"", timeNow, url];
			if(sqlite3_exec(db, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) {
				// do nothing but ignore.
			}
		}
	}
	pthread_mutex_unlock(&lock);
	return [data autorelease];
}

- (BOOL)push:(NSData *)data forKey:(NSString *)url {
	const char *sql = "INSERT OR REPLACE INTO IMAGES(URL, TIME, SIZE, DATA) VALUES(?, ?, ?, ?);";
	if(pthread_mutex_lock(&lock))
		return NO;
	sqlite3_stmt *stmt = NULL;
	if(sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) != SQLITE_OK) {
		pthread_mutex_unlock(&lock);
		return NO;
	}
	
	sqlite3_bind_text(stmt, 1, [url UTF8String], [url length], NULL);
	
	NSDate *now = [[NSDate alloc] init];
	sqlite3_bind_int(stmt, 2, [now timeIntervalSince1970]);
	[now release];
	
	sqlite3_bind_int(stmt, 3, [data length]);
	
	if(sqlite3_bind_blob(stmt, 4, [data bytes], [data length], NULL) != SQLITE_OK) {
		sqlite3_finalize(stmt);
		pthread_mutex_unlock(&lock);
		return NO;
	}
	
	BOOL result = (SQLITE_DONE == sqlite3_step(stmt));
	sqlite3_finalize(stmt);
	
	pthread_mutex_unlock(&lock);
	return result;
}

- (BOOL)cleanUp {
	BOOL result = YES;
	if(pthread_mutex_lock(&lock))
		return NO;
	if(sqlite3_exec(db, "BEGIN TRANSACTION", NULL, NULL, NULL) != SQLITE_OK) {
		pthread_mutex_unlock(&lock);
		return NO;
	}
	do {
		const char *sql = "SELECT COUNT(_ROWID_) FROM IMAGES;";
		sqlite3_stmt *stmt = NULL;
		if(sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) != SQLITE_OK) {
			result = NO;
			break;
		}
		
		if(sqlite3_step(stmt) != SQLITE_ROW) {
			result = NO;
			break;
		}
		
		int count = sqlite3_column_int(stmt, 0);
		sqlite3_finalize(stmt);
		
		count = count - [self maxCount];
		if(count <= 0)
			break;
		
		sql = "SELECT TIME FROM IMAGES ORDER BY TIME ASC;";
		stmt = NULL;
		if(sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) != SQLITE_OK) {
			result = NO;
			break;
		}
		
		NSInteger minTime = NSIntegerMax;
		for(int i = 0; i < count; i++) {
			if(SQLITE_DONE == sqlite3_step(stmt)) {
				break;
			}
		}
		minTime = sqlite3_column_int(stmt, 0);
		sqlite3_finalize(stmt);
		
		NSString *sqlstr = [[NSString alloc] initWithFormat:@"DELETE FROM IMAGES WHERE TIME <= %d", minTime];
		if(SQLITE_OK != sqlite3_exec(db, [sqlstr UTF8String], NULL, NULL, NULL)) {
			result = NO;
			[sqlstr release];
			break;
		}
		[sqlstr release];
	} while(NO);
	
	if(result && sqlite3_exec(db, "COMMIT", NULL, NULL, NULL) != SQLITE_OK)
		result = NO;
	
	if(result) {
	} else {
		sqlite3_exec(db, "ROLLBACK", NULL, NULL, NULL);
	}
	
	pthread_mutex_unlock(&lock);
	return result;
}

- (void)dealloc {
	[filename release];
	sqlite3_close(db);
	pthread_mutex_destroy(&lock);
	[super dealloc];
}

@end
