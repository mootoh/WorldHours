#ifdef DEBUG

#define LOG(...) LOG(__VA_ARGS__)
#define LOG_CURRENT_METHOD LOG(NSStringFromSelector(_cmd))

#else // DEBUG

#define LOG(...) ;
#define LOG_CURRENT_METHOD ;

#endif // DEBUG
