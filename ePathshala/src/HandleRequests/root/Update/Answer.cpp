#include "Answer.h"

void UpdateAnswer(Json::Value &request, drogon::orm::DbClient &dbClient)
{
    std::clog << "Update \"answer\"" << std::endl;

    std::stringstream queryStream;

    queryStream.str("CALL UPDATE_ANSWER($1, $2)");

    dbClient.execSqlAsyncFuture(queryStream.str(), request["answer_id"].asInt64(), request["answer"].asString());
}