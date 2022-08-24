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
    // Json::Value initData;
    std::vector<std::pair<std::string, std::fstream>> downloads(1000);
	drogon::HttpAppFramework &httpAppFramework = drogon::app();

    httpAppFramework.loadConfigFile("./data/config.json");

    drogon::orm::DbClientPtr dbClientPtr = drogon::orm::DbClient::newPgClient("user=epathshala dbname=epathshala password=1234", 1);
    drogon::orm::DbClient &dbClient = *dbClientPtr;

	httpAppFramework.registerHandler("/",
    [&dbClient, &httpAppFramework, &downloads](const drogon::HttpRequestPtr &req, std::function<void(const drogon::HttpResponsePtr &)> &&callback)
    {
        std::shared_ptr<Json::Value> reqJsonPtr = req->getJsonObject();
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
        else if(request["type"].asString() == "buy-course")
        {
            BuyCourse(request, response, dbClient);
        }
        else if(request["type"].asString() == "get-teacher-details")
        {
            GetTeacherDetails(request, response, dbClient);
        }
        else if(request["type"].asString() == "get-courses-teacher")
        {
            GetCoursesTeacher(request, response, dbClient);
        }
        else if(request["type"].asString() == "update-user-details")
        {
            UpdateUserDetails(request, response, dbClient);
        }
        else if(request["type"].asString() == "update-pfp")
        {
            UpdatePfp(request, response, httpAppFramework);
        }
        else if(request["type"].asString() == "insert-new-course")
        {
            InsertCourse(request, response, dbClient);
        }
        else if(request["type"].asString() == "post-comment")
        {
            PostComment(request, dbClient);
        }
        else if(request["type"].asString() == "delete-comment")
        {
            DeleteComment(request, dbClient);
        }
        else if(request["type"].asString() == "update-comment-rate")
        {
            UpdateCommentRate(request, dbClient);
        }
        else if(request["type"].asString() == "update-comment")
        {
            UpdateComment(request, dbClient);
        }

        std::clog << "Sending response" << std::endl;

        drogon::HttpResponsePtr httpResponsePtr = drogon::HttpResponse::newHttpJsonResponse(response);
        
        callback(httpResponsePtr);
    },
    {drogon::Post});

    httpAppFramework.registerHandler("/server-test",
    [](const drogon::HttpRequestPtr &httpRequestPtr, std::function<void(const drogon::HttpResponsePtr &)> &&callback)
    {
        std::clog << "***server-test***" << std::endl;

        drogon::HttpResponsePtr httpResponsePtr = drogon::HttpResponse::newHttpResponse();
        httpResponsePtr->setBody("Hello");

        callback(httpResponsePtr);
    }, {drogon::Post});

	httpAppFramework.run();

	return 0;
}