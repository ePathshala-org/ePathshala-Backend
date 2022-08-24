#include "Comment.h"

void PostComment(Json::Value &request, drogon::orm::DbClient &dbClient)
{
    std::clog << "Post \"comment\"" << std::endl;

    std::stringstream queryStream;

    queryStream.str("CALL POST_COMMENT($1, $2, $3)");

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["user_id"].asInt64(), request["content_id"].asInt64(), request["description"].asString());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();
}