#include "AnswerRate.h"

void UpdateAnswerRate(Json::Value &request, drogon::orm::DbClient &dbClient)
{
    std::clog << "update \"answer-rate\"" << std::endl;

    std::stringstream queryStream;

    queryStream.str("CALL UPDATE_ANSWER_RATE($1, $2, $3)");
    dbClient.execSqlAsyncFuture(queryStream.str(), request["user_id"], request["answer_id"].asInt64(), request["rate"].asInt());
}