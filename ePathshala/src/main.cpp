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

	httpAppFramework.registerHandler("/",
    [&dbClient](const drogon::HttpRequestPtr &req, std::function<void(const drogon::HttpResponsePtr &)> &&callback)
    {
        std::shared_ptr<Json::Value> reqJsonPtr = req.get()->getJsonObject();
        Json::Value &requestJson = *reqJsonPtr.get();
        Json::Value response;

        if(requestJson["type"].asString() == "init-not-logged-in")
        {
            InitNotLoggedIn(requestJson, response, dbClient);
        }
        else if(requestJson["type"].asString() == "login")
        {
            Login(requestJson, response, dbClient);
        }
        else if(requestJson["type"].asString() == "get-student-details-home")
        {
            GetStudentDetailsHome(requestJson, response, dbClient);
        }
        else if(requestJson["type"].asString() == "get-teacher-details-home")
        {
            GetTeacherDetailsHome(requestJson, response, dbClient);
        }
        else if(requestJson["type"].asString() == "get-teacher-courses")
        {
            GetTeacherCourses(requestJson, response, dbClient);
        }
        else if(requestJson["type"].asString() == "search")
        {
            Search(requestJson, response, dbClient);
        }
        else if(requestJson["type"].asString() == "get-student-courses")
        {
            GetStudentCourses(requestJson, response, dbClient);
        }
        else if(requestJson["type"].asString() == "get-student-all-courses")
        {
            GetStudentAllCourses(requestJson, response, dbClient);
        }
        else if(requestJson["type"].asString() == "create-new-account")
        {
            CreateNewAccount(requestJson, response, dbClient);
        }
        else if(requestJson["type"].asString() == "get-course-contents")
        {
            GetCourseContents(requestJson, response, dbClient);
        }
        else if(requestJson["type"].asString() == "get-student-details")
        {
            GetStudentDetails(requestJson, response, dbClient);
        }
        else if(requestJson["type"].asString() == "get-all-courses")
        {
            GetAllCourses(requestJson, response, dbClient);
        }
        else if(requestJson["type"].asString() == "get-course-details")
        {
            GetCourseDetails(requestJson, response, dbClient);
        }
        else if(requestJson["type"].asString() == "get-content-course-id")
        {
            GetContentCourseId(requestJson, response, dbClient);
        }

        std::clog << "Sending response" << std::endl;

        drogon::HttpResponsePtr httpResponsePtr = drogon::HttpResponse::newHttpJsonResponse(response);
        
        callback(httpResponsePtr);
    },
    {drogon::Post});

	httpAppFramework.run();

	return 0;
}