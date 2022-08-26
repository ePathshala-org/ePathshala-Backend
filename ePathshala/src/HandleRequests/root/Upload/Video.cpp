#include "Video.h"

void UploadVideo(drogon::HttpRequestPtr httpRequestPtr, Json::Value &response, drogon::orm::DbClient &dbClient, drogon::HttpAppFramework &httpAppFramework)
{
    std::clog << "Upload \"video\" request" << std::endl;

    Json::Int64 courseId;
    std::stringstream courseIdStream(httpRequestPtr->getHeader("course_id"));
    Json::String title(httpRequestPtr->getHeader("title"));
    Json::String description(httpRequestPtr->getHeader("description"));

    courseIdStream >> courseId;

    std::string docRoot = httpAppFramework.getDocumentRoot();
    std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture("SELECT INSERT_CONTENT($1, $2, $3, $4) AS NEW_CONTENT_ID", "VIDEO", courseId, title, description);

    resultFuture.wait();

    drogon::orm::Result result = resultFuture.get();

    std::string parent = docRoot + "/contents/videos/" + httpRequestPtr->getHeader("course_id");

    if(!std::filesystem::exists(parent))
    {
        std::filesystem::create_directories(parent);
    }

    drogon::MultiPartParser multipartParser;

    multipartParser.parse(httpRequestPtr);

    std::string newFilePath = parent + "/" + result[0]["NEW_CONTENT_ID"].as<Json::String>() + ".mp4";
    std::fstream fileStream(newFilePath, std::fstream::binary | std::fstream::out);

    fileStream << multipartParser.getFiles()[0].fileContent();

    fileStream.close();

    response["ok"] = true;
}