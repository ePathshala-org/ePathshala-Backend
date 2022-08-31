#include "Answer.h"

void DeleteAnswer(Json::Value &request, drogon::orm::DbClient &dbClient)
{
    std::clog << "Delete \"answer\"" << std::endl;

    std::stringstream queryStream;

    queryStream.str("CALL DELETE_ANSWER($1)");

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["answer_id"].asInt64());
}