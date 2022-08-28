#include "GetQuestionDetails.h"

void GetQuestionDetails(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient, drogon::HttpAppFramework &httpAppFramework)
{
    std::clog << "Get \"question-details\" request" << std::endl;

    std::stringstream queryStream("SELECT * FROM GET_QUESTION_DETAILS($1)");

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["question_id"].asInt64());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    if(result.size() > 0)
    {
        std::string docRoot = httpAppFramework.getDocumentRoot();
        std::string path = docRoot + "/questions/" + request["question_id"].asString() + ".json";
        std::ifstream fileStream(path);
        std::string content;

        for(size_t i = 0; i < request["select"].size(); ++i)
        {
            Json::Value defaultValue = Json::nullValue;

            if(request["select"].get(i, defaultValue).asString() == "CONTENT")
            {
                fileStream >> response["CONTENT"];
            }
            else
            {
                std::string column = request["select"].get(i, defaultValue).asString();
                response[column] = result[0][column].as<Json::String>();
            }
        }

        fileStream.close();
        
        response["ok"] = true;
    }
}