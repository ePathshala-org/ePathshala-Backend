#include <iostream>
#include <fstream>
#include <algorithm>
#include <drogon/drogon.h>
#include <drogon/orm/DbClient.h>
#include "SetupInitData.h"
#include "SetupDbClientPtr.h"

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
            std::clog << "Got \"init-not-logged-in\" request" << std::endl;

            std::ifstream inputFileStream("../sql/init-not-logged-in/top-courses.sql");
            std::stringstream queryStream;

            queryStream << inputFileStream.rdbuf();

            std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str());

            resultFuture.wait();

            drogon::orm::Result result = resultFuture.get();

            std::clog << "Prepared top-courses" << std::endl;

            for(long i = 0; i < result.size() && i < 5; ++i)
            {
                Json::Value responseRow;

                responseRow["course_id"] = result[i]["COURSE_ID"].as<Json::Int64>();
                responseRow["title"] = result[i]["TITLE"].as<Json::String>();
                responseRow["description"] = result[i]["DESCRIPTION"].as<Json::String>();
                responseRow["price"] = result[i]["PRICE"].as<Json::Int64>();
                responseRow["rate"] = result[i]["RATE"].as<double>();
                responseRow["number_of_enrolls"] = result[i]["NUMBER_OF_ENROLLS"].as<Json::Int64>();

                response["query_top_courses"].append(responseRow);
            }

            queryStream.str("");
            inputFileStream.close();
            inputFileStream.open("../sql/init-not-logged-in/top-videos.sql");

            queryStream << inputFileStream.rdbuf();

            resultFuture = dbClient.execSqlAsyncFuture(queryStream.str());

            resultFuture.wait();

            result = resultFuture.get();

            for(long i = 0; i < result.size() && i < 5; ++i)
            {
                Json::Value responseRow;

                responseRow["content_id"] = result[i]["CONTENT_ID"].as<Json::Int64>();
                responseRow["title"] = result[i]["TITLE"].as<Json::String>();
                responseRow["description"] = result[i]["DESCRIPTION"].as<Json::String>();
                responseRow["number_of_viewers"] = result[i]["NUMBER_OF_VIEWERS"].as<Json::Int64>();

                response["query_top_videos"].append(responseRow);
            }

            response["ok"] = true;

            inputFileStream.close();
        }
        else if(requestJson["type"].asString() == "login")
        {
            if(requestJson["account_type"].as<Json::String>() == "student")
            {
                std::clog << "Got \"login student\" request" << std::endl;

                std::ifstream inputFileStream("../sql/login/student/check-email.sql");
                std::stringstream queryStream;

                queryStream << inputFileStream.rdbuf();

                std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), requestJson["email"].asString());

                resultFuture.wait();

                drogon::orm::Result result = resultFuture.get();

                if(result.size() > 0)
                {
                    std::clog << "Email found" << std::endl;

                    response["email_found"] = true;
                }
                else
                {
                    std::clog << "Login not accepted" << std::endl;

                    response["email_found"] = false;
                }

                if(response["email_found"].as<bool>())
                {
                    queryStream.str("");
                    inputFileStream.close();
                    inputFileStream.open("../sql/login/student/email-found.sql");

                    queryStream << inputFileStream.rdbuf();

                    resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), requestJson["email"].asString(), requestJson["password"].asString());

                    resultFuture.wait();

                    result = resultFuture.get();

                    if(result.size() > 0)
                    {
                        std::clog << "Password matched" << std::endl;

                        response["password_matched"] = true;
                    }
                    else
                    {
                        response["password_matched"] = false;
                    }
                }

                if(response["password_matched"].as<bool>())
                {
                    response["user_id"] = result[0]["USER_ID"].as<Json::Int64>();
                    response["password"] = result[0]["SECURITY_KEY"].as<Json::String>();
                    response["account_type"] = "student";
                }

                inputFileStream.close();
            }
            else
            {
                std::clog << "Got \"login teacher\" request" << std::endl;

                std::ifstream inputFileStream("../sql/login/teacher/check-email.sql");
                std::stringstream queryStream;

                queryStream << inputFileStream.rdbuf();

                std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), requestJson["email"].asString());

                resultFuture.wait();

                drogon::orm::Result result = resultFuture.get();

                if(result.size() > 0)
                {
                    std::clog << "Email found" << std::endl;

                    response["email_found"] = true;
                }
                else
                {
                    std::clog << "Login not accepted" << std::endl;

                    response["email_found"] = false;
                }

                if(response["email_found"].as<bool>())
                {
                    queryStream.str("");
                    inputFileStream.close();
                    inputFileStream.open("../sql/login/teacher/email-found.sql");

                    queryStream << inputFileStream.rdbuf();

                    resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), requestJson["email"].asString(), requestJson["password"].asString());

                    resultFuture.wait();

                    result = resultFuture.get();

                    if(result.size() > 0)
                    {
                        std::clog << "Password matched" << std::endl;

                        response["password_matched"] = true;
                    }
                    else
                    {
                        response["password_matched"] = false;
                    }
                }

                if(response["password_matched"].as<bool>())
                {
                    response["user_id"] = result[0]["USER_ID"].as<Json::Int64>();
                    response["password"] = result[0]["SECURITY_KEY"].as<Json::String>();
                    response["account_type"] = "teacher";
                }

                inputFileStream.close();
            }
            
            response["ok"] = true;
        }
        else if(requestJson["type"].asString() == "get-student-details-home")
        {
            std::clog << "Get \"student-details-home\" request" << std::endl;

            std::ifstream inputFileStream("../sql/get-student-details-home.sql");
            std::stringstream queryStream;

            queryStream << inputFileStream.rdbuf();

            std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), requestJson["user_id"].as<Json::Int64>(), requestJson["password"].as<Json::String>());

            resultFuture.wait();

            drogon::orm::Result result = resultFuture.get();

            if(result.size())
            {
                std::clog << "Making response" << std::endl;

                response["ok"] = true;
                response["full_name"] = result[0]["FULL_NAME"].as<Json::String>();
                response["email"] = result[0]["EMAIL"].as<Json::String>();
                response["bio"] = result[0]["BIO"].as<Json::String>();
                response["rank_point"] = result[0]["RANK_POINT"].as<Json::Int>();
            }
            else
            {
                std::clog << "No such user id, could not make response" << std::endl;

                response["ok"] = false;
            }

            inputFileStream.close();
        }
        else if(requestJson["type"].asString() == "get-teacher-details-home")
        {
            std::clog << "Get \"teacher-details-home\" request" << std::endl;

            std::ifstream inputFileStream("../sql/get-teacher-details-home.sql");
            std::stringstream queryStream;

            queryStream << inputFileStream.rdbuf();

            std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), requestJson["user_id"].as<Json::Int64>());

            resultFuture.wait();

            drogon::orm::Result result = resultFuture.get();

            if(result.size())
            {
                std::clog << "Making response" << std::endl;

                response["ok"] = true;
                response["full_name"] = result[0]["FULL_NAME"].as<Json::String>();
                response["email"] = result[0]["EMAIL"].as<Json::String>();
                response["bio"] = result[0]["BIO"].as<Json::String>();
                response["rate"] = result[0]["RATE"].as<Json::String>();
            }
            else
            {
                std::clog << "No such user id, could not make response" << std::endl;

                response["ok"] = false;
            }

            inputFileStream.close();
        }
        else if(requestJson["type"].asString() == "get-teacher-courses")
        {
            std::clog << "Got \"teacher-courses\"" << std::endl;

            std::ifstream inputFileStream("../sql/get-teacher-courses.sql");
            std::stringstream queryStream;

            queryStream << inputFileStream.rdbuf();

            std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), requestJson["user_id"].as<Json::Int64>());

            resultFuture.wait();

            drogon::orm::Result result = resultFuture.get();

            std::clog << "Making response" << std::endl;

            for(long i = 0; i < result.size() && i < 5; ++i)
            {
                Json::Value responseRow;

                responseRow["course_id"] = result[i]["COURSE_ID"].as<Json::Int64>();
                responseRow["title"] = result[i]["TITLE"].as<Json::String>();
                responseRow["description"] = result[i]["DESCRIPTION"].as<Json::String>();
                responseRow["price"] = result[i]["PRICE"].as<Json::Int64>();
                responseRow["rate"] = result[i]["RATE"].as<double>();

                response["query_user_courses"].append(responseRow);
            }

            response["ok"] = true;

            inputFileStream.close();
        }
        else if(requestJson["type"].asString() == "search")
        {
            std::clog << "Search request" << std::endl;

            if(requestJson["search_type"].asString() == "courses")
            {
                std::clog << "Courses search request" << std::endl;

                std::ifstream inputFileStream("../sql/search/courses/search-result.sql");
                std::string searchQuery = requestJson["search_query"].asString();
                std::stringstream queryStream;
                long page = requestJson["page"].as<Json::Int64>();

                queryStream << inputFileStream.rdbuf();

                std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), searchQuery);

                resultFuture.wait();

                drogon::orm::Result result = resultFuture.get();

                response["max_page_count"] = 0;
                response["returned_page"] = 0;
                long startIndex = 0;

                if(result.size() > 0)
                {
                    response["max_page_count"] = (result.size() - 1) / 5 + 1;
                    page = (page < response["max_page_count"].as<Json::Int64>() ? page : response["max_page_count"].as<Json::Int64>());
                    page = (page > 0) ? page : 0;
                    startIndex = 5 * page;
                    response["returned_page"] = (Json::Int64)page;
                }                    

                for(long i = startIndex; i < result.size() && i < startIndex + 5; ++i)
                {
                    Json::Value row;

                    row["course_id"] = result[i]["COURSE_ID"].as<Json::Int64>();
                    row["title"] = result[i]["TITLE"].as<Json::String>();
                    row["description"] = result[i]["DESCRIPTION"].as<Json::String>();
                    row["price"] = result[i]["PRICE"].as<Json::Int64>();
                    row["rate"] = result[i]["RATE"].as<double>();

                    response["search_result_courses"].append(row);
                }

                response["ok"] = true;

                inputFileStream.close();
            }
            else if(requestJson["search_type"].asString() == "videos")
            {
                std::clog << "Videos search request" << std::endl;

                std::ifstream inputFileStream("../sql/search/videos/search-result.sql");
                std::string searchQuery = requestJson["search_query"].asString();
                long page = requestJson["page"].as<Json::Int64>();
                std::stringstream queryStream;

                queryStream << inputFileStream.rdbuf();

                std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), searchQuery);

                resultFuture.wait();

                drogon::orm::Result result = resultFuture.get();

                response["max_page_count"] = 0;
                response["returned_page"] = 0;
                long startIndex = 0;

                if(result.size() > 0)
                {
                    response["max_page_count"] = (result.size() - 1) / 5 + 1;
                    page = (page < response["max_page_count"].as<Json::Int64>() ? page : response["max_page_count"].as<Json::Int64>());
                    page = (page > 0) ? page : 0;
                    startIndex = 5 * page;
                    response["returned_page"] = (Json::Int64)page;
                }

                for(long i = startIndex; i < result.size() && i < startIndex + 5; ++i)
                {
                    Json::Value row;

                    row["content_id"] = result[i]["CONTENT_ID"].as<Json::Int64>();
                    row["video_title"] = result[i]["CONTENT_TITLE"].as<Json::String>();
                    row["course_id"] = result[i]["COURSE_ID"].as<Json::String>();
                    row["description"] = result[i]["DESCRIPTION"].as<Json::String>();
                    row["course_title"] = result[i]["COURSE_TITLE"].as<Json::String>();
                    row["rate"] = result[i]["RATE"].as<double>();

                    response["search_result_videos"].append(row);
                }

                response["ok"] = true;

                inputFileStream.close();
            }
            else if(requestJson["search_type"].asString() == "pages")
            {
                std::clog << "Pages search request" << std::endl;

                std::ifstream inputFileStream("../sql/search/pages/search-result.sql");
                std::string searchQuery = requestJson["search_query"].asString();
                long page = requestJson["page"].as<Json::Int64>();
                std::stringstream queryStream;

                queryStream << inputFileStream.rdbuf();

                std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), searchQuery);

                resultFuture.wait();

                drogon::orm::Result result = resultFuture.get();

                response["max_page_count"] = 0;
                response["returned_page"] = 0;
                long startIndex = 0;

                if(result.size() > 0)
                {
                    response["max_page_count"] = (result.size() - 1) / 5 + 1;
                    page = (page < response["max_page_count"].as<Json::Int64>() ? page : response["max_page_count"].as<Json::Int64>());
                    page = (page > 0) ? page : 0;
                    startIndex = 5 * page;
                    response["returned_page"] = (Json::Int64)page;
                }

                for(long i = startIndex; i < result.size() && i < startIndex + 5; ++i)
                {
                    Json::Value row;

                    row["content_id"] = result[i]["CONTENT_ID"].as<Json::Int64>();
                    row["page_title"] = result[i]["CONTENT_TITLE"].as<Json::String>();
                    row["course_id"] = result[i]["COURSE_ID"].as<Json::String>();
                    row["description"] = result[i]["DESCRIPTION"].as<Json::String>();
                    row["course_title"] = result[i]["COURSE_TITLE"].as<Json::String>();
                    row["rate"] = result[i]["RATE"].as<double>();

                    response["search_result_pages"].append(row);
                }

                response["ok"] = true;

                inputFileStream.close();
            }
            else if(requestJson["search_type"].asString() == "quizes")
            {
                std::clog << "Quizes search request" << std::endl;

                std::ifstream inputFileStream("../sql/search/search-result.sql");
                std::string searchQuery = requestJson["search_query"].asString();
                long page = requestJson["page"].as<Json::Int64>();
                std::stringstream queryStream;

                queryStream << inputFileStream.rdbuf();

                std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), searchQuery);

                resultFuture.wait();

                drogon::orm::Result result = resultFuture.get();

                response["max_page_count"] = 0;
                response["returned_page"] = 0;
                long startIndex = 0;

                if(result.size() > 0)
                {

                    response["max_page_count"] = (result.size() - 1) / 5 + 1;
                    page = (page < response["max_page_count"].as<Json::Int64>() ? page : response["max_page_count"].as<Json::Int64>());
                    page = (page > 0) ? page : 0;
                    startIndex = 5 * page;
                    response["returned_page"] = (Json::Int64)page;
                }

                for(long i = startIndex; i < result.size() && i < startIndex + 5; ++i)
                {
                    Json::Value row;

                    row["content_id"] = result[i]["CONTENT_ID"].as<Json::Int64>();
                    row["quiz_title"] = result[i]["CONTENT_TITLE"].as<Json::String>();
                    row["course_id"] = result[i]["COURSE_ID"].as<Json::String>();
                    row["description"] = result[i]["DESCRIPTION"].as<Json::String>();
                    row["course_title"] = result[i]["COURSE_TITLE"].as<Json::String>();
                    row["rate"] = result[i]["RATE"].as<double>();

                    response["search_result_quizes"].append(row);
                }

                response["ok"] = true;

                inputFileStream.close();
            }
            else if(requestJson["search_type"].asString() == "students")
            {
                std::clog << "Students search request" << std::endl;

                std::ifstream inputFileStream("../sql/search/students/search-result.sql");
                std::string searchQuery = requestJson["search_query"].asString();
                long page = requestJson["page"].as<Json::Int64>();
                std::stringstream queryStream;

                queryStream << inputFileStream.rdbuf();

                std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), searchQuery);

                resultFuture.wait();

                drogon::orm::Result result = resultFuture.get();

                response["max_page_count"] = 0;
                response["returned_page"] = 0;
                long startIndex = 0;

                if(result.size() > 0)
                {
                    response["max_page_count"] = (result.size() - 1) / 5 + 1;
                    page = (page < response["max_page_count"].as<Json::Int64>() ? page : response["max_page_count"].as<Json::Int64>());
                    page = (page > 0) ? page : 0;
                    startIndex = 5 * page;
                    response["returned_page"] = (Json::Int64)page;
                }

                for(long i = startIndex; i < result.size() && i < startIndex + 5; ++i)
                {
                    Json::Value row;

                    row["user_id"] = result[i]["USER_ID"].as<Json::Int64>();
                    row["rank_point"] = result[i]["RANK_POINT"].as<Json::String>();
                    row["full_name"] = result[i]["FULL_NAME"].as<Json::String>();

                    response["search_result_students"].append(row);
                }

                response["ok"] = true;

                inputFileStream.close();
            }
            else if(requestJson["search_type"].asString() == "teachers")
            {
                std::clog << "Teachers search request" << std::endl;

                std::ifstream inputFileStream("../sql/teachers/search-result.sql");
                std::string searchQuery = requestJson["search_query"].asString();
                long page = requestJson["page"].as<Json::Int64>();
                std::stringstream queryStream;

                queryStream << inputFileStream.rdbuf();

                std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), searchQuery);

                resultFuture.wait();

                drogon::orm::Result result = resultFuture.get();

                response["max_page_count"] = 0;
                response["returned_page"] = 0;
                long startIndex = 0;

                if(result.size() > 0)
                {
                    response["max_page_count"] = (result.size() - 1) / 5 + 1;
                    page = (page < response["max_page_count"].as<Json::Int64>() ? page : response["max_page_count"].as<Json::Int64>());
                    page = (page > 0) ? page : 0;
                    startIndex = 5 * page;
                    response["returned_page"] = (Json::Int64)page;
                }

                for(long i = startIndex; i < result.size() && i < startIndex + 5; ++i)
                {
                    Json::Value row;

                    row["user_id"] = result[i]["USER_ID"].as<Json::Int64>();
                    row["rate"] = result[i]["RATE"].as<double>();
                    row["full_name"] = result[i]["FULL_NAME"].as<Json::String>();

                    response["search_result_teachers"].append(row);
                }

                response["ok"] = true;

                inputFileStream.close();
            }
        }
        else if(requestJson["type"].asString() == "get-student-courses")
        {
            std::clog << "Got students courses request" << std::endl;

            std::ifstream inputFileStream("get-student-courses.sql");
            std::stringstream queryStream;

            queryStream << inputFileStream.rdbuf();

            std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), requestJson["user_id"].as<Json::Int64>());

            resultFuture.wait();

            drogon::orm::Result result = resultFuture.get();

            std::clog << "Making response" << std::endl;

            for(long i = 0; i < result.size() && i < 5; ++i)
            {
                Json::Value responseRow;

                responseRow["course_id"] = result[i]["COURSE_ID"].as<Json::Int64>();
                responseRow["title"] = result[i]["TITLE"].as<Json::String>();
                responseRow["description"] = result[i]["DESCRIPTION"].as<Json::String>();
                responseRow["price"] = result[i]["PRICE"].as<Json::Int64>();
                responseRow["rate"] = result[i]["RATE"].as<double>();
                responseRow["number_of_enrolls"] = result[i]["NUMBER_OF_ENROLLS"].as<Json::Int>();

                response["query_user_courses"].append(responseRow);
            }

            response["ok"] = true;

            inputFileStream.close();
        }
        else if(requestJson["type"].asString() == "get-student-all-courses")
        {
            std::clog << "Get \"student-all-courses\" request" << std::endl;

            std::ifstream inputFileStream("../sql/get-student-all-courses.sql");
            std::stringstream queryStream;

            queryStream << inputFileStream.rdbuf();

            std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str());

            resultFuture.wait();

            drogon::orm::Result result = resultFuture.get();

            std::clog << "Making response" << std::endl;

            for(long i = 0; i < result.size(); ++i)
            {
                Json::Value responseRow;

                responseRow["course_id"] = result[i]["COURSE_ID"].as<Json::Int64>();
                responseRow["title"] = result[i]["TITLE"].as<Json::String>();
                responseRow["description"] = result[i]["DESCRIPTION"].as<Json::String>();
                responseRow["price"] = result[i]["PRICE"].as<Json::Int64>();
                responseRow["rate"] = result[i]["RATE"].as<double>();
                responseRow["number_of_enrolls"] = result[i]["NUMBER_OF_ENROLLS"].as<Json::Int64>();

                response["query_user_courses"].append(responseRow);
            }

            response["ok"] = true;

            inputFileStream.close();
        }
        else if(requestJson["type"].asString() == "create-new-account")
        {
            std::clog << "Get \"create-new-account\" request" << std::endl;

            std::ifstream inputFileStream("../sql/create-new-account/check-email-in-users.sql");
            std::stringstream queryStream;

            queryStream << inputFileStream.rdbuf();

            std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str(), requestJson["email"].asString());

            resultFuture.wait();

            drogon::orm::Result result = resultFuture.get();

            inputFileStream.close();

            int64_t nextUserId;

            if
            (
                result.size() > 0 && 
                (
                    requestJson["student"].asBool() && result[0]["USER_TYPE"].as<std::string>() == "STUDENT" ||
                    !requestJson["student"].asBool() && result[0]["USER_TYPE"].as<std::string>() == "TEACHER"
                )
            )
            {
                nextUserId = 0;
            }
            else
            {
                std::clog << "Finding appropriate ID for new user" << std::endl;

                inputFileStream.open("../sql/create-new-account/get-max-user-id.sql");
                queryStream.str("");

                queryStream << inputFileStream.rdbuf();

                std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(queryStream.str());

                resultFuture.wait();

                drogon::orm::Result result = resultFuture.get();

                inputFileStream.close();

                if(result.size() == 0)
                {
                    nextUserId = 1;
                }
                else
                {
                    nextUserId = result[0]["MAX_USER_ID"].as<int64_t>() + 1;
                }
            }

            if(nextUserId > 0)
            {
                std::string gender = "F";

                if(requestJson["male"].asBool())
                {
                    gender = "M";
                }

                std::string date = requestJson["date_of_birth"]["date"].asString();
                std::string month = requestJson["date_of_birth"]["month"].asString();
                std::string year = requestJson["date_of_birth"]["year"].asString();
                std::string dateOfBirth = date + "-" + month + "-" + year;

                inputFileStream.open("../sql/create-new-account/create-new-account.sql");
                queryStream.str("");

                queryStream << inputFileStream.rdbuf();

                std::string userType = "TEACHER";

                if(requestJson["student"].asBool())
                {
                    userType = "STUDENT";
                }

                std::clog << "Creating new user" << std::endl;

                dbClient.execSqlAsyncFuture(queryStream.str(), nextUserId, requestJson["name"].asString(), requestJson["email"].asString(), requestJson["password"].asString(), userType, gender);

                response["email_exists"] = false;
                response["user_id"] = nextUserId;
                response["password"] = requestJson["password"].asString();
                
                if(userType == "STUDENT")
                {
                    response["account_type"] = "student";
                }
                else
                {
                    response["account_type"] = "teacher";
                }
            }
            else
            {
                response["email_exists"] = true;
            }

            response["ok"] = true;
        }

        std::clog << "Sending response" << std::endl;

        Json::FastWriter responseFastWriter;

        std::string responseText = responseFastWriter.write(response);

        std::clog << responseText << std::endl;

        drogon::HttpResponsePtr httpResponsePtr = drogon::HttpResponse::newHttpJsonResponse(response);
        callback(httpResponsePtr);
    },
    {drogon::Post});

	httpAppFramework.run();

	return 0;
}