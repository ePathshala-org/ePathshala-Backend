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
    std::vector<std::pair<std::string, std::fstream>> downloads(1000);
	drogon::HttpAppFramework &httpAppFramework = drogon::app();

    httpAppFramework.loadConfigFile("./data/config.json");

    drogon::orm::DbClientPtr dbClientPtr = drogon::orm::DbClient::newPgClient("user=epathshala dbname=epathshala password=1234", 1);
    drogon::orm::DbClient &dbClient = *dbClientPtr;

	httpAppFramework.registerHandler("/",
    [&dbClient, &httpAppFramework, &downloads](const drogon::HttpRequestPtr &httpRequestPtr, std::function<void(const drogon::HttpResponsePtr &)> &&callback)
    {
        Json::Value response;

        // std::clog << *httpRequestPtr.get()->jsonObject().get() << std::endl;

        if(httpRequestPtr->getHeader("incoming") == "video-file")
        {
            UploadVideo(httpRequestPtr, response, dbClient, httpAppFramework);
        }
        else if(httpRequestPtr->getHeader("type") == "update-video")
        {
            UpdateVideo(httpRequestPtr, response, dbClient, httpAppFramework);
        }
        else if(httpRequestPtr->getHeader("type") == "create-new-account")
        {
            std::shared_ptr<Json::Value> reqJsonPtr = httpRequestPtr->getJsonObject();
            Json::Value &request = *reqJsonPtr.get();

            InsertUser(request, response, dbClient, httpAppFramework);
        }
        else if(httpRequestPtr->getHeader("type") == "insert-question")
        {
            std::shared_ptr<Json::Value> reqJsonPtr = httpRequestPtr->getJsonObject();
            Json::Value &request = *reqJsonPtr.get();

            InsertQuestion(request, response, dbClient, httpAppFramework);
        }
        else if(httpRequestPtr->getHeader("type") == "get-questions")
        {
            std::shared_ptr<Json::Value> reqJsonPtr = httpRequestPtr->getJsonObject();
            Json::Value &request = *reqJsonPtr.get();

            GetQuestions(request, response, dbClient);
        }
        else if(httpRequestPtr->getHeader("type") == "get-question-details")
        {
            std::shared_ptr<Json::Value> reqJsonPtr = httpRequestPtr->getJsonObject();
            Json::Value &request = *reqJsonPtr.get();

            GetQuestionDetails(request, response, dbClient, httpAppFramework);
        }
        else if(httpRequestPtr->getHeader("type") == "login")
        {
            std::shared_ptr<Json::Value> reqJsonPtr = httpRequestPtr->getJsonObject();
            Json::Value &request = *reqJsonPtr.get();

            Login(request, response, dbClient);
        }
        else if(httpRequestPtr->getHeader("type") == "get-page-content")
        {
            std::shared_ptr<Json::Value> reqJsonPtr = httpRequestPtr->getJsonObject();
            Json::Value &request = *reqJsonPtr.get();

            GetPageContent(request, response, dbClient, httpAppFramework);
        }
        else if(httpRequestPtr->getHeader("type") == "insert-page")
        {
            std::shared_ptr<Json::Value> reqJsonPtr = httpRequestPtr->getJsonObject();
            Json::Value &request = *reqJsonPtr.get();

            InsertPage(request, response, dbClient, httpAppFramework);
        }
        else if(httpRequestPtr->getHeader("type") == "update-page")
        {
            std::shared_ptr<Json::Value> reqJsonPtr = httpRequestPtr->getJsonObject();
            Json::Value &request = *reqJsonPtr.get();

            UpdatePage(request, response, dbClient, httpAppFramework);
        }
        else if(httpRequestPtr->getHeader("type") == "insert-view")
        {
            std::shared_ptr<Json::Value> reqJsonPtr = httpRequestPtr->getJsonObject();
            Json::Value &request = *reqJsonPtr.get();

            InsertView(request, response, dbClient);
        }
        else if(httpRequestPtr->getHeader("type") == "update-content-rate")
        {
            std::shared_ptr<Json::Value> reqJsonPtr = httpRequestPtr->getJsonObject();
            Json::Value &request = *reqJsonPtr.get();

            UpdateContentRate(request, response, dbClient);
        }
        else if(httpRequestPtr->getHeader("type") == "get-individual-content-rate")
        {
            std::shared_ptr<Json::Value> reqJsonPtr = httpRequestPtr->getJsonObject();
            Json::Value &request = *reqJsonPtr.get();

            GetIndividualContentRate(request, response, dbClient);
        }
        else if(httpRequestPtr->getHeader("type") == "complete-view")
        {
            std::shared_ptr<Json::Value> reqJsonPtr = httpRequestPtr->getJsonObject();
            Json::Value &request = *reqJsonPtr.get();

            CompleteView(request, response, dbClient);
        }
        else if(httpRequestPtr->getHeader("type") == "search-courses")
        {
            std::shared_ptr<Json::Value> reqJsonPtr = httpRequestPtr->getJsonObject();
            Json::Value &request = *reqJsonPtr.get();

            SearchCourses(request, response, dbClient);
        }
        else if(httpRequestPtr->getHeader("type") == "search-videos")
        {
            std::shared_ptr<Json::Value> reqJsonPtr = httpRequestPtr->getJsonObject();
            Json::Value &request = *reqJsonPtr.get();

            SearchVideos(request, response, dbClient);
        }
        else if(httpRequestPtr->getHeader("type") == "search-pages")
        {
            std::shared_ptr<Json::Value> reqJsonPtr = httpRequestPtr->getJsonObject();
            Json::Value &request = *reqJsonPtr.get();

            SearchPages(request, response, dbClient);
        }
        else if(httpRequestPtr->getHeader("type") == "collect-credit")
        {
            std::shared_ptr<Json::Value> reqJsonPtr = httpRequestPtr->getJsonObject();
            Json::Value &request = *reqJsonPtr.get();

            CollectCredit(request, response, dbClient);
        }
        else
        {
            std::shared_ptr<Json::Value> reqJsonPtr = httpRequestPtr->getJsonObject();
            Json::Value &request = *reqJsonPtr.get();

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
            else if(request["type"].asString() == "get-interests")
            {
                GetInterests(request, response, dbClient);
            }
            else if(request["type"].asString() == "delete-interest")
            {
                DeleteInterest(request, dbClient);
            }
            else if(request["type"].asString() == "insert-student")
            {
                InsertStudent(request, dbClient);
            }
            else if(request["type"].asString() == "insert-teacher")
            {
                InsertTeacher(request, dbClient);
            }
            else if(request["type"].asString() == "insert-interest")
            {
                InsertInterest(request, dbClient);
            }
            else if(request["type"].asString() == "delete-course")
            {
                DeleteCourse(request, dbClient);
            }
            else if(request["type"].asString() == "get-specialities")
            {
                GetSpecialities(request, response, dbClient);
            }
            else if(request["type"].asString() == "insert-speciality")
            {
                InsertSpeciality(request, dbClient);
            }
            else if(request["type"].asString() == "delete-speciality")
            {
                DeleteSpeciality(request, dbClient);
            }
            else if(request["type"].asString() == "delete-content")
            {
                DeleteContent(request, dbClient);
            }
            else if(request["type"].asString() == "update-course")
            {
                UpdateCourse(request, dbClient);
            }
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

        std::clog << httpRequestPtr->getHeader("Incoming") << std::endl;
        std::ofstream f("/home/siam11651/Desktop/hehe", std::fstream::out);
        f << httpRequestPtr->getBody();

        f.close();

        // std::clog << httpRequestPtr->getBody() << std::endl;

        drogon::HttpResponsePtr httpResponsePtr = drogon::HttpResponse::newHttpResponse();
        
        callback(httpResponsePtr);
    }, {drogon::Post});

	httpAppFramework.run();

	return 0;
}