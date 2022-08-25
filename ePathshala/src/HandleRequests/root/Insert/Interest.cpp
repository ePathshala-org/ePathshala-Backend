#include "Interest.h"

void InsertInterest(Json::Value &request, drogon::orm::DbClient &dbClient)
{
    std::clog << "Insert \"interest\" request" << std::endl;
    std::clog << request << std::endl;

    std::stringstream queryStream("CALL INSERT_INTEREST($1, $2)");

    dbClient.execSqlAsyncFuture(queryStream.str(), request["student_id"].asInt64(), request["interest"].asString());
}