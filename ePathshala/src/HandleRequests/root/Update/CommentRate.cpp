#include "CommentRate.h"

void UpdateCommentRate(Json::Value &request, drogon::orm::DbClient &dbClient)
{
    std::clog << "update \"comment-rate\"" << std::endl;

    std::stringstream queryStream;

    queryStream.str("CALL update_comment_rate($1, $2)");
    dbClient.execSqlAsyncFuture(queryStream.str(), request["comment_id"].asInt64(), request["rate"].asDouble());
}