#include "GetCoursesStudent.h"

void GetCoursesStudent(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Get \"course-student\" request" << std::endl;

    std::ifstream inputFileStream("./sql/get-courses-student.sql");
    std::stringstream queryStream;

    queryStream << inputFileStream.rdbuf();

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["user_id"].asInt64());

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

        response["courses"].append(content);
    }

    response["ok"] = true;
}