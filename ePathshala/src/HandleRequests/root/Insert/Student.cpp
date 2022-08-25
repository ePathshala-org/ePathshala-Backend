#include "Student.h"

void InsertStudent(Json::Value &request, drogon::orm::DbClient &dbClient)
{
    std::clog << "Insert \"student\" request" << std::endl;

    std::stringstream queryStream("CALL INSERT_STUDENT($1)");

    dbClient.execSqlAsyncFuture(queryStream.str(), request["user_id"].asInt64());
}