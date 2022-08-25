#include "Interest.h"

void DeleteInterest(Json::Value &request, drogon::orm::DbClient &dbClient)
{
    std::clog << "Delete \"interest\" request" << std::endl;

    std::stringstream queryStream;

    queryStream.str("CALL DELETE_INTEREST($1, $2)");
    dbClient.execSqlAsyncFuture(queryStream.str(), request["student_id"].asInt64(), request["interest"].asString());
}