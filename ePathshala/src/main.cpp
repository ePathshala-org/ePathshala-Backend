#include <iostream>
#include <fstream>
#include <algorithm>
#include <drogon/drogon.h>
#include <drogon/orm/DbClient.h>
#include "SetupInitData.h"
#include "SetupDbClientPtr.h"
#include "HandleRequests/HandleRequests.h"

int main()
{
    Json::Value initData;

    SetupInitData(initData);

    drogon::orm::DbClientPtr dbClientPtr = GetDbClientPtr(initData);
    drogon::orm::DbClient &dbClient = *dbClientPtr.get();

	drogon::HttpAppFramework &httpAppFramework = drogon::app().addListener(initData["ip"].asString(), initData["port"].asInt());

	httpAppFramework.setThreadNum(16);
    httpAppFramework.setDocumentRoot(initData["docRoot"].asString());
    httpAppFramework.setFileTypes({"gif", "png", "jpg", "js", "css", "html", "ico", "swf", "xap", "apk", "cur", "xml", "mp4", "webm", "ogg"});

	httpAppFramework.registerHandler("/",
    [&dbClient](const drogon::HttpRequestPtr &req, std::function<void(const drogon::HttpResponsePtr &)> &&callback)
    {
        std::shared_ptr<Json::Value> reqJsonPtr = req.get()->getJsonObject();
        Json::Value &request = *reqJsonPtr.get();
        Json::Value response;

        std::clog << "type: " << request["type"].asString() << std::endl;

        if(request["type"].asString() == "get-user-details")
        {
            GetUserDetails(request, response, dbClient);
        }
        else if(request["type"].asString() == "get-user-id")
        {
            GetUserId(request, response, dbClient);
        }
        else if(request["type"].asString() == "get-courses-popular")
        {
            GetCoursesPopular(request, response, dbClient);
        }
        else if(request["type"].asString() == "get-course-details")
        {
            GetCourseDetails(request, response, dbClient);
        }
        else if(request["type"].asString() == "get-course-contents")
        {
            GetCourseContents(request, response, dbClient);
        }
        else if(request["type"].asString() == "get-content-details")
        {
            GetContentDetails(request, response, dbClient);
        }
        else if(request["type"].asString() == "get-comments")
        {
            GetComments(request, response, dbClient);
        }
        else if(request["type"].asString() == "get-student-details")
        {
            GetStudentDetails(request, response, dbClient);
        }
        else if(request["type"].asString() == "get-courses-student")
        {
            GetCoursesStudent(request, response, dbClient);
        }
        else if(request["type"].asString() == "get-course-remain-content-count")
        {
            GetCourseRemainContentCount(request, response, dbClient);
        }
        else if(request["type"].asString() == "check-user-enrolled")
        {
            CheckUserEnrolled(request, response, dbClient);
        }

        std::clog << "Sending response" << std::endl;

        drogon::HttpResponsePtr httpResponsePtr = drogon::HttpResponse::newHttpJsonResponse(response);
        
        callback(httpResponsePtr);
    },
    {drogon::Post});

	httpAppFramework.run();

	return 0;
}