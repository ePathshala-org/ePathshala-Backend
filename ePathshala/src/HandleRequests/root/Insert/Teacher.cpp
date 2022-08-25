#include "Teacher.h"

void InsertTeacher(Json::Value &request, drogon::orm::DbClient &dbClient)
{
    std::clog << "Insert \"teacher\" request" << std::endl;

    std::stringstream queryStream;

    queryStream.str("CALL INSERT_TEACHER($1)");
    dbClient.execSqlAsyncFuture(queryStream.str(), request["user_id"].asInt64());
}