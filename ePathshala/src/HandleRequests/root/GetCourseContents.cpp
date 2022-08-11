#include "GetCourseContents.h"

void GetCourseContents(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Get \"course-contents\" request" << std::endl;

    std::ifstream inputFileStream("./sql/get-contents.sql");
    std::stringstream queryStream;

    queryStream << inputFileStream.rdbuf();

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["course_id"].asInt64());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    for(size_t i = 0; i < result.size(); ++i)
    {
        Json::Value content;

        for(size_t j = 0; j < request["select"].size(); ++j)
        {
            Json::String defaultValue = "null";
            std::string column = request["select"].get(j, defaultValue).asString();
            content[column] = result[i][column].as<Json::String>();
        }

        response["contents"].append(content);
    }

    response["ok"] = true;
}