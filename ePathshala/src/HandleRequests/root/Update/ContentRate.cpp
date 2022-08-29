#include "ContentRate.h"

void UpdateContentRate(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Update \"content-rate\" request" << std::endl;

    std::stringstream queryStream("CALL UPDATE_CONTENT_RATE($1, $2, $3)");

    dbClient.execSqlAsyncFuture(queryStream.str(), request["user_id"].asInt64(), request["content_id"].asInt64(), request["rate"].asInt());

    response["ok"] = true;
}