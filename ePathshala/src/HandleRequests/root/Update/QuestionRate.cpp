#include "QuestionRate.h"

void UpdateQuestionRate(Json::Value &request, drogon::orm::DbClient &dbClient)
{
    std::clog << "update \"question-rate\"" << std::endl;

    std::stringstream queryStream;

    queryStream.str("CALL UPDATE_QUESTION_RATE($1, $2, $3)");
    dbClient.execSqlAsyncFuture(queryStream.str(), request["user_id"], request["question_id"].asInt64(), request["rate"].asInt());
}