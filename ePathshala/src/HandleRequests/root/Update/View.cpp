#include "View.h"

void CompleteView(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Update \"view\" request" << std::endl;

    std::stringstream queryStream("CALL COMPLETE_VIEW($1, $2)");

    dbClient.execSqlAsyncFuture(queryStream.str(), request["user_id"].asInt64(), request["content_id"].asInt64());
}