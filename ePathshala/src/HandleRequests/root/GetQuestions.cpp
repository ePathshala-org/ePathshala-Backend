#include "GetQuestions.h"

void GetQuestions(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::cout << "Get \"questions\" request" << std::endl;

    std::stringstream queryStream("SELECT * FROM GET_QUESTIONS()");

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    for(size_t i = 0; i < result.size(); ++i)
    {
        Json::Value question;

        for(size_t j = 0; j < request["select"].size(); ++j)
        {
            Json::String defaultValue = "null";
            std::string column = request["select"].get(j, defaultValue).asString();
            question[column] = result[i][column].as<Json::String>();
        }

        response["questions"].append(question);
    }

    response["ok"] = true;
}