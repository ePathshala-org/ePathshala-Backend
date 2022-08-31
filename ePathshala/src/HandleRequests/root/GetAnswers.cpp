#include "GetAnswers.h"

void GetAnswers(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Get \"get-answers\" request" << std::endl;

    std::stringstream queryStream;

    queryStream.str("SELECT * FROM GET_ANSWERS_BY_TIME_DESC($1)");

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["question_id"].asInt64());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    for(size_t i = 0; i < result.size(); ++i)
    {
        Json::Value answer;

        for(size_t j = 0; j < request["select"].size(); ++j)
        {
            Json::Value defaultValue = Json::nullValue;
            std::string column = request["select"].get(j, defaultValue).asString();
            answer[column] = result[i][column].as<Json::String>();
        }

        response["answers"].append(answer);
    }

    response["ok"] = true;
}