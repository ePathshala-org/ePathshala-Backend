#include "Question.h"

void InsertQuestion(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient, drogon::HttpAppFramework &httpAppFramework)
{
    std::clog << "Insert \"question\" request" << std::endl;

    std::stringstream queryStream("SELECT INSERT_QUESTION($1, $2, $3) AS RETURN");

    Json::String tagsString = "{";

    for(size_t i = 0; i < request["tags"].size(); ++i)
    {
        if(i == 0)
        {
            tagsString += "\"" + request["tags"].get(i, Json::nullValue).asString() + "\"";
        }
        else
        {
            tagsString += ",\"" + request["tags"].get(i, Json::nullValue).asString() + "\"";
        }
    }

    tagsString += "}";

    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), request["title"].asString(), tagsString, request["asker_id"].asInt64());

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    if(result[0]["RETURN"].as<Json::Int64>() != -1)
    {
        std::string fileName = result[0]["RETURN"].as<Json::String>();
        std::string docRoot = httpAppFramework.getDocumentRoot();
        std::string path = docRoot + "/questions/" + fileName + ".json";
        std::ofstream fileStream(path);

        fileStream << request["content"];

        fileStream.close();
    }

    response["return"] = result[0]["RETURN"].as<Json::Int64>();
    response["ok"] = true;
}