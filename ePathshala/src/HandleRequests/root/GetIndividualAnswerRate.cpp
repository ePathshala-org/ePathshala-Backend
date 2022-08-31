#include "GetIndividualAnswerRate.h"

void GetIndividualAnswerRate(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Get \"individual-answer-rate\" request" << std::endl;

    std::stringstream queryStream("SELECT GET_INDIVIDUAL_ANSWER_RATE($1, $2) AS RETURN");

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["user_id"].asInt64(), request["answer_id"].asInt64());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    response["rate"] = result[0]["RETURN"].as<Json::Int>();
    response["ok"] = true;
}