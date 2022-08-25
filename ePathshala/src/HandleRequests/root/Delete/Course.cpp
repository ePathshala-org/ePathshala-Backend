#include "Course.h"

void DeleteCourse(Json::Value &request, drogon::orm::DbClient &dbClient)
{
    std::clog << "Delete \"course\" request" << std::endl;

    std::stringstream queryStream("CALL DELETE_COURSE($1)");
    
    dbClient.execSqlAsyncFuture(queryStream.str(), request["course_id"].asInt64());
}