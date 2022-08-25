#include "Course.h"

void UpdateCourse(Json::Value &request, drogon::orm::DbClient &dbClient)
{
    std::clog << "Update \"course\" request" << std::endl;

    std::stringstream queryStream("CALL UPDATE_COURSE($1, $2, $3, $4)");

    dbClient.execSqlAsyncFuture(queryStream.str(), request["course_id"].asInt64(), request["title"].asString(), request["description"].asString(), request["price"].asInt());
}