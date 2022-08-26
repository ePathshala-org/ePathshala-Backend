#include "Video.h"

void UpdateVideo(drogon::HttpRequestPtr httpRequestPtr, Json::Value &response, drogon::orm::DbClient &dbClient, drogon::HttpAppFramework &httpAppFramework)
{
    std::clog << "Update \"video\" request" << std::endl;

    std::stringstream contentIdStream(httpRequestPtr->getHeader("content_id"));
    Json::Int64 contentId;

    contentIdStream >> contentId;

    Json::String title = httpRequestPtr->getHeader("title");
    Json::String description = httpRequestPtr->getHeader("description");
    std::stringstream queryStream("SELECT UPDATE_VIDEO($1, $2, $3) AS RETURN");
    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), contentId, title, description);

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    if(result[0]["RETURN"].as<Json::Int>() == 0 && httpRequestPtr->getHeader("file_changed") == "true")
    {
        drogon::MultiPartParser multiPartParser;

        multiPartParser.parse(httpRequestPtr);

        std::shared_future<drogon::orm::Result> courseResultFuture = dbClient.execSqlAsyncFuture("SELECT * FROM GET_CONTENT_DETAILS($1)", contentId);

        courseResultFuture.wait();

        drogon::orm::Result courseResult = courseResultFuture.get();

        std::string docroot = httpAppFramework.getDocumentRoot();
        std::stringstream path;

        path << docroot << "/contents/videos/" << courseResult[0]["COURSE_ID"].as<Json::String>() << "/" << contentId << ".mp4";

        remove(path.str().c_str());

        std::ofstream fileStream(path.str(), std::fstream::binary);

        fileStream << multiPartParser.getFiles()[0].fileContent();

        fileStream.close();
    }
    
    response["return"] = result[0]["RETURN"].as<Json::Int>();
    response["ok"] = true;
}