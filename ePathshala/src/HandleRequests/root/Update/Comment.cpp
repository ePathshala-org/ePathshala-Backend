#include "Comment.h"

void UpdateComment(Json::Value &request, drogon::orm::DbClient &dbClient)
{
    std::clog << "Update \"comment\"" << std::endl;

    std::stringstream queryStream;

    queryStream.str("CALL update_comment($1, $2)");

    dbClient.execSqlAsyncFuture(queryStream.str(), request["comment_id"].asInt64(), request["description"].asString());
}