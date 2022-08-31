#include "Question.h"

void UpdateQuestion(Json::Value &request, drogon::HttpAppFramework &httpAppFramework)
{
    std::clog << "Update \"question\" request" << std::endl;

    std::string docRoot = httpAppFramework.getDocumentRoot();
    std::string path = docRoot + "/questions/" + request["question_id"].asString() + ".json";
    std::ofstream fileStream(path);

    fileStream << request["content"];

    fileStream.close();
}