#include "GetComments.h"

void GetComments(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Get \"get-comments\" request" << std::endl;

    std::ifstream inputFileStream("./sql/get-comments.sql");
    std::stringstream queryStream;

    queryStream << inputFileStream.rdbuf();

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["content_id"].asInt64());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    for(size_t i = 0; i < result.size(); ++i)
    {
        Json::Value comment;

        for(size_t j = 0; j < request["select"].size(); ++j)
        {
            Json::String defaultValue = "null";
            std::string column = request["select"].get(j, defaultValue).asString();
            comment[column] = result[i][column].as<Json::String>();
        }

        response["comments"].append(comment);
    }

    response["ok"] = true;
}