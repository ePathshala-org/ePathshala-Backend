#include "GetComments.h"

void GetComments(Json::Value &requestJson, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Get \"get-comments\" request" << std::endl;

    std::ifstream inputFileStream("./sql/get-comments.sql");
    std::stringstream queryStream;

    queryStream << inputFileStream.rdbuf();

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), requestJson["content_id"].asInt64());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    for(size_t i = 0; i < result.size(); ++i)
    {
        Json::Value comment;
        comment["comment_id"] = result[i]["COMMENT_ID"].as<Json::Int64>();
        comment["content_id"] = result[i]["CONTENT_ID"].as<Json::Int64>();
        comment["commenter_id"] = result[i]["COMMENTER_ID"].as<Json::Int64>();
        comment["commenter_name"] = result[i]["COMMENTER_NAME"].as<Json::String>();
        comment["description"] = result[i]["DESCRIPTION"].as<Json::String>();
        comment["time_of_comment"] = result[i]["TIME_OF_COMMENT"].as<Json::String>();
        comment["date_of_comment"] = result[i]["DATE_OF_COMMENT"].as<Json::String>();
        comment["rate"] = result[i]["RATE"].as<double>();

        response["comments"].append(comment);
    }
}