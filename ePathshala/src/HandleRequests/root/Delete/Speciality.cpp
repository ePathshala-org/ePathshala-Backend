#include "Speciality.h"

void DeleteSpeciality(Json::Value &request, drogon::orm::DbClient &dbClient)
{
    std::clog << "Delete \"speciality\" request" << std::endl;

    std::stringstream queryStream("CALL DELETE_SPECIALITY($1, $2)");

    dbClient.execSqlAsyncFuture(queryStream.str(), request["teacher_id"].asInt64(), request["speciality"].asString());
}