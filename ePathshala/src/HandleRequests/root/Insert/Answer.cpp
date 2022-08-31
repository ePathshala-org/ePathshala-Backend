#include "Answer.h"

void PostAnswer(Json::Value &request, drogon::orm::DbClient &dbClient)
{
    std::clog << "Post \"answer\"" << std::endl;

    std::stringstream queryStream;

    queryStream.str("CALL POST_ANSWER($1, $2, $3)");

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["user_id"].asInt64(), request["question_id"].asInt64(), request["answer"].asString());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();
}