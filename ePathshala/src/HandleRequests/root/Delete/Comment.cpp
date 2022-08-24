#include "Comment.h"

void DeleteComment(Json::Value &request, drogon::orm::DbClient &dbClient)
{
    std::clog << "Delete \"comment\"" << std::endl;

    std::stringstream queryStream;

    queryStream.str("CALL DELETE_COMMENT($1)");

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["comment_id"].asInt64());
}