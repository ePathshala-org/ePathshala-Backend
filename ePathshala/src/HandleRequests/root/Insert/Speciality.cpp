#include "Speciality.h"

void InsertSpeciality(Json::Value &request, drogon::orm::DbClient &dbClient)
{
    std::clog << "Insert \"speciality\" request" << std::endl;
    std::clog << request << std::endl;

    std::stringstream queryStream("CALL INSERT_SPECIALITY($1, $2)");

    dbClient.execSqlAsyncFuture(queryStream.str(), request["teacher_id"].asInt64(), request["speciality"].asString());
}