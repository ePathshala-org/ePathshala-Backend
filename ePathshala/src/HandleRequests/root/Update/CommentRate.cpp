#include "CommentRate.h"

void UpdateCommentRate(Json::Value &request, drogon::orm::DbClient &dbClient)
{
    std::clog << "update \"comment-rate\"" << std::endl;

    std::stringstream queryStream;

    queryStream.str("CALL UPDATE_COMMENT_RATE($1, $2, $3)");
    dbClient.execSqlAsyncFuture(queryStream.str(), request["user_id"], request["comment_id"].asInt64(), request["rate"].asInt());
}