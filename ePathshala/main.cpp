#include <iostream>
#include <algorithm>
#include <drogon/drogon.h>
#include <drogon/orm/DbClient.h>

int main()
{
    drogon::orm::DbClientPtr dbClientPtr = drogon::orm::DbClient::newPgClient("user=epathshala password=1234 dbname=epathshala", 1);
    drogon::orm::DbClient &dbClient = *dbClientPtr.get();

	drogon::HttpAppFramework &httpAppFramework = drogon::app().addListener("127.0.0.1", 8080);

	httpAppFramework.setThreadNum(16);
    httpAppFramework.setDocumentRoot("/mnt/hdd/Sources/ePathshala");

	httpAppFramework.registerHandler("/",
    [&dbClient](const drogon::HttpRequestPtr &req, std::function<void(const drogon::HttpResponsePtr &)> &&callback)
    {
        std::shared_ptr<Json::Value> reqJsonPtr = req.get()->getJsonObject();
        Json::Value &requestJson = *reqJsonPtr.get();
        Json::Value response;

        if(requestJson["type"].asString() == "init-not-logged-in")
        {
            std::cout << "Got init request" << std::endl;

            std::stringstream query;
            query <<
                "SELECT COURSES_2.COURSE_ID AS COURSE_ID, COURSES_2.TITLE AS TITLE, COURSES_2.DESCRIPTION AS DESCRIPTION, PRICE, NUMBER_OF_ENROLLS, AVG(RATE) AS RATE\
                FROM(\
                    SELECT COURSES.COURSE_ID AS COURSE_ID, TITLE, DESCRIPTION, PRICE, COUNT(*) AS NUMBER_OF_ENROLLS\
                    FROM COURSES\
                    JOIN ENROLLED_COURSES\
                    ON(COURSES.COURSE_ID = ENROLLED_COURSES.COURSE_ID)\
                    GROUP BY COURSES.COURSE_ID, TITLE, DESCRIPTION, PRICE\
                ) COURSES_2\
                JOIN CONTENTS\
                ON(COURSES_2.COURSE_ID = CONTENTS.COURSE_ID)\
                GROUP BY COURSES_2.COURSE_ID, COURSES_2.TITLE, COURSES_2.DESCRIPTION, PRICE, NUMBER_OF_ENROLLS\
                ORDER BY NUMBER_OF_ENROLLS DESC";

            std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(query.str());

            resultFuture.wait();

            drogon::orm::Result result = resultFuture.get();

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

            query.str("");

            query <<
                "SELECT CONTENTS.CONTENT_ID AS CONTENT_ID, TITLE, DESCRIPTION, COUNT(*) AS NUMBER_OF_VIEWERS\
                FROM CONTENTS\
                JOIN CONTENT_VIEWERS\
                ON(CONTENTS.CONTENT_ID = CONTENT_VIEWERS.CONTENT_ID)\
                GROUP BY CONTENTS.CONTENT_ID, TITLE, DESCRIPTION\
                ORDER BY NUMBER_OF_VIEWERS DESC";

            resultFuture = dbClient.execSqlAsyncFuture(query.str());

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
        }
        else if(requestJson["type"].asString() == "login")
        {
            if(requestJson["account_type"].as<Json::String>() == "student")
            {
                std::cout << "Got student login request" << std::endl;

                std::string query = "SELECT STUDENTS.USER_ID AS USER_ID\
                FROM STUDENTS\
                JOIN USERS\
                ON(STUDENTS.USER_ID = USERS.USER_ID)\
                WHERE EMAIL = \'" + requestJson["email"].asString() + "\'";

                std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(query);

                resultFuture.wait();

                drogon::orm::Result result = resultFuture.get();

                if(result.size() > 0)
                {
                    std::cout << "Email found" << std::endl;

                    response["email_found"] = true;
                }
                else
                {
                    std::cout << "Login not accepted" << std::endl;

                    response["email_found"] = false;
                }

                if(response["email_found"].as<bool>())
                {
                    query = "SELECT STUDENTS.USER_ID AS USER_ID, SECURITY_KEY\
                    FROM STUDENTS\
                    JOIN USERS\
                    ON(STUDENTS.USER_ID = USERS.USER_ID)\
                    WHERE EMAIL = \'" + requestJson["email"].asString() + "\' AND SECURITY_KEY = \'" + requestJson["password"].asString() + "\'";

                    resultFuture = dbClient.execSqlAsyncFuture(query);

                    resultFuture.wait();

                    result = resultFuture.get();

                    if(result.size() > 0)
                    {
                        std::cout << "Password matched" << std::endl;

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
            }
            else
            {
                std::cout << "Got teacher login request" << std::endl;

                std::string query = "SELECT TEACHERS.USER_ID AS USER_ID\
                    FROM TEACHERS\
                    JOIN USERS\
                    ON(TEACHERS.USER_ID = USERS.USER_ID)\
                    WHERE EMAIL = \'" + requestJson["email"].asString() + "\'";

                std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(query);

                resultFuture.wait();

                drogon::orm::Result result = resultFuture.get();

                if(result.size() > 0)
                {
                    std::cout << "Email found" << std::endl;

                    response["email_found"] = true;
                }
                else
                {
                    std::cout << "Login not accepted" << std::endl;

                    response["email_found"] = false;
                }

                if(response["email_found"].as<bool>())
                {
                    query = "SELECT TEACHERS.USER_ID AS USER_ID, SECURITY_KEY\
                    FROM TEACHERS\
                    JOIN USERS\
                    ON(TEACHERS.USER_ID = USERS.USER_ID)\
                    WHERE EMAIL = \'" + requestJson["email"].asString() + "\' AND SECURITY_KEY = \'" + requestJson["password"].asString() + "\'";

                    resultFuture = dbClient.execSqlAsyncFuture(query);

                    resultFuture.wait();

                    result = resultFuture.get();

                    if(result.size() > 0)
                    {
                        std::cout << "Password matched" << std::endl;

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
            }
            

            response["ok"] = true;
        }
        else if(requestJson["type"].asString() == "get-student-details-home")
        {
            std::cout << "Get student details request" << std::endl;

            std::stringstream query;

            query << "SELECT FULL_NAME, EMAIL, BIO, RANK_POINT\
                FROM USERS\
                JOIN STUDENTS\
                ON (USERS.USER_ID = STUDENTS.USER_ID)\
                WHERE USERS.USER_ID = " << requestJson["user_id"].as<Json::Int64>() << " AND SECURITY_KEY = \'" << requestJson["password"].as<Json::String>() << "\'";

            std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(query.str());

            resultFuture.wait();

            drogon::orm::Result result = resultFuture.get();

            if(result.size())
            {
                std::cout << "Making response" << std::endl;

                response["ok"] = true;
                response["full_name"] = result[0]["FULL_NAME"].as<Json::String>();
                response["email"] = result[0]["EMAIL"].as<Json::String>();
                response["bio"] = result[0]["BIO"].as<Json::String>();
                response["rank_point"] = result[0]["RANK_POINT"].as<Json::Int>();
            }
            else
            {
                std::cout << "No such user id, could not make response" << std::endl;

                response["ok"] = false;
            }
        }
        else if(requestJson["type"].asString() == "get-teacher-details-home")
        {
            std::cout << "Teacher details request" << std::endl;

            std::stringstream query;

            query << "SELECT FULL_NAME, EMAIL, BIO, AVG(RATE) AS RATE\
                FROM USERS\
                JOIN TEACHERS\
                ON(USERS.USER_ID = TEACHERS.USER_ID)\
                JOIN COURSES\
                ON(TEACHERS.USER_ID = COURSES.CREATOR_ID)\
                JOIN CONTENTS\
                ON(COURSES.COURSE_ID = CONTENTS.COURSE_ID)\
                WHERE USERS.USER_ID = " << requestJson["user_id"].as<Json::Int64>() << " \
                GROUP BY FULL_NAME, EMAIL, BIO";

            std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(query.str());

            resultFuture.wait();

            drogon::orm::Result result = resultFuture.get();

            if(result.size())
            {
                std::cout << "Making response" << std::endl;

                response["ok"] = true;
                response["full_name"] = result[0]["FULL_NAME"].as<Json::String>();
                response["email"] = result[0]["EMAIL"].as<Json::String>();
                response["bio"] = result[0]["BIO"].as<Json::String>();
                response["rate"] = result[0]["RATE"].as<Json::String>();
            }
            else
            {
                std::cout << "No such user id, could not make response" << std::endl;

                response["ok"] = false;
            }
        }
        else if(requestJson["type"].asString() == "get-teacher-courses")
        {
            std::stringstream query;

            query << "SELECT COURSES.COURSE_ID AS COURSE_ID, COURSES.TITLE AS TITLE, COURSES.DESCRIPTION AS DESCRIPTION, PRICE, AVG(RATE) AS RATE\
                FROM COURSES\
                JOIN CONTENTS\
                ON(COURSES.COURSE_ID = CONTENTS.COURSE_ID)\
                WHERE CREATOR_ID = " << requestJson["user_id"].as<Json::Int64>() <<
                "GROUP BY COURSES.COURSE_ID, COURSES.TITLE, COURSES.DESCRIPTION\
                ORDER BY RATE";

            std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(query.str());

            resultFuture.wait();

            drogon::orm::Result result = resultFuture.get();

            std::cout << "Making response" << std::endl;

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
        }
        else if(requestJson["type"].asString() == "search")
        {
            std::cout << "Search request" << std::endl;

            if(requestJson["search_type"].asString() == "courses")
            {
                std::cout << "Courses search request" << std::endl;

                std::string searchQuery = requestJson["search_query"].asString();
                std::stringstream query;
                long page = requestJson["page"].as<Json::Int64>();

                query <<
                    "SELECT COURSES.COURSE_ID AS COURSE_ID, COURSES.TITLE AS TITLE, COURSES.DESCRIPTION AS DESCRIPTION, PRICE, AVG(RATE) AS RATE\
                    FROM COURSES\
                    JOIN CONTENTS\
                    ON(COURSES.COURSE_ID = CONTENTS.COURSE_ID)\
                    WHERE LOWER(COURSES.TITLE) LIKE LOWER(\'%" << searchQuery << "%\')\
                    GROUP BY COURSES.COURSE_ID, COURSES.TITLE, COURSES.DESCRIPTION, PRICE";

                std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(query.str());

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
            }
            else if(requestJson["search_type"].asString() == "videos")
            {
                std::cout << "Videos search request" << std::endl;

                std::string searchQuery = requestJson["search_query"].asString();
                long page = requestJson["page"].as<Json::Int64>();
                std::stringstream query;

                query <<
                    "SELECT CONTENT_ID, CONTENTS.TITLE AS CONTENT_TITLE, CONTENTS.DESCRIPTION AS DESCRIPTION, RATE, CONTENTS.COURSE_ID AS COURSE_ID, COURSES.TITLE AS COURSE_TITLE\
                    FROM CONTENTS\
                    JOIN COURSES\
                    ON(CONTENTS.COURSE_ID = COURSES.COURSE_ID)\
                    WHERE LOWER(CONTENTS.TITLE) LIKE LOWER(\'%" << searchQuery << "%\') AND CONTENT_TYPE = \'VIDEOS\'";

                std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(query.str());

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
            }
            else if(requestJson["search_type"].asString() == "pages")
            {
                std::cout << "Pages search request" << std::endl;

                std::string searchQuery = requestJson["search_query"].asString();
                long page = requestJson["page"].as<Json::Int64>();
                std::stringstream query;

                query <<
                    "SELECT CONTENT_ID, CONTENTS.TITLE AS CONTENT_TITLE, CONTENTS.DESCRIPTION AS DESCRIPTION, RATE, CONTENTS.COURSE_ID AS COURSE_ID, COURSES.TITLE AS COURSE_TITLE\
                    FROM CONTENTS\
                    JOIN COURSES\
                    ON(CONTENTS.COURSE_ID = COURSES.COURSE_ID)\
                    WHERE LOWER(CONTENTS.TITLE) LIKE LOWER(\'%" << searchQuery << "%\') AND CONTENT_TYPE = \'PAGE\'";

                std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(query.str());

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
            }
            else if(requestJson["search_type"].asString() == "quizes")
            {
                std::cout << "Quizes search request" << std::endl;

                std::string searchQuery = requestJson["search_query"].asString();
                long page = requestJson["page"].as<Json::Int64>();
                std::stringstream query;

                query <<
                    "SELECT CONTENT_ID, CONTENTS.TITLE AS CONTENT_TITLE, CONTENTS.DESCRIPTION AS DESCRIPTION, RATE, CONTENTS.COURSE_ID AS COURSE_ID, COURSES.TITLE AS COURSE_TITLE\
                    FROM CONTENTS\
                    JOIN COURSES\
                    ON(CONTENTS.COURSE_ID = COURSES.COURSE_ID)\
                    WHERE LOWER(CONTENTS.TITLE) LIKE LOWER(\'%" << searchQuery << "%\') AND CONTENT_TYPE = \'QUIZ\'";

                std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(query.str());

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
            }
            else if(requestJson["search_type"].asString() == "students")
            {
                std::cout << "Students search request" << std::endl;

                std::string searchQuery = requestJson["search_query"].asString();
                long page = requestJson["page"].as<Json::Int64>();
                std::stringstream query;

                query <<
                    "SELECT STUDENTS.USER_ID AS USER_ID, FULL_NAME, RANK_POINT\
                    FROM STUDENTS\
                    JOIN USERS\
                    ON(USERS.USER_ID = STUDENTS.USER_ID)\
                    WHERE LOWER(FULL_NAME) LIKE LOWER(\'%" << searchQuery << "%\')";

                std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(query.str());

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
            }
            else if(requestJson["search_type"].asString() == "teachers")
            {
                std::cout << "Teachers search request" << std::endl;

                std::string searchQuery = requestJson["search_query"].asString();
                long page = requestJson["page"].as<Json::Int64>();
                std::stringstream query;

                query <<
                    "SELECT TEACHERS.USER_ID AS USER_ID, FULL_NAME, AVG(RATE) AS RATE\
                    FROM TEACHERS\
                    JOIN USERS\
                    ON(USERS.USER_ID = TEACHERS.USER_ID)\
                    JOIN COURSES\
                    ON(TEACHERS.USER_ID = COURSES.CREATOR_ID)\
                    JOIN CONTENTS\
                    ON(COURSES.COURSE_ID = CONTENTS.COURSE_ID)\
                    WHERE LOWER(FULL_NAME) LIKE LOWER(\'%" << searchQuery << "%\')\
                    GROUP BY TEACHERS.USER_ID, FULL_NAME";

                std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(query.str());

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
            }
        }
        else if(requestJson["type"].asString() == "get-student-courses")
        {
            std::cout << "Got students courses request" << std::endl;

            std::stringstream query;

            query <<
                "SELECT COURSES_2.COURSE_ID AS COURSE_ID, COURSES_2.TITLE AS TITLE, COURSES_2.DESCRIPTION AS DESCRIPTION, PRICE, NUMBER_OF_ENROLLS, AVG(RATE) AS RATE\
                    FROM(\
                        SELECT COURSES.COURSE_ID AS COURSE_ID, TITLE, DESCRIPTION, PRICE, COUNT(*) AS NUMBER_OF_ENROLLS\
                        FROM COURSES\
                        JOIN ENROLLED_COURSES\
                        ON(COURSES.COURSE_ID = ENROLLED_COURSES.COURSE_ID)\
                        WHERE ENROLLED_COURSES.USER_ID = " << requestJson["user_id"].as<Json::Int64>() <<
                        "GROUP BY COURSES.COURSE_ID, TITLE, DESCRIPTION, PRICE\
                    ) COURSES_2\
                    JOIN CONTENTS\
                    ON(COURSES_2.COURSE_ID = CONTENTS.COURSE_ID)\
                    GROUP BY COURSES_2.COURSE_ID, COURSES_2.TITLE, COURSES_2.DESCRIPTION, PRICE, NUMBER_OF_ENROLLS\
                    ORDER BY NUMBER_OF_ENROLLS DESC, RATE DESC";

            std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(query.str());

            resultFuture.wait();

            drogon::orm::Result result = resultFuture.get();

            std::cout << "Making response" << std::endl;

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
        }
        else if(requestJson["type"].asString() == "get-student-all-courses")
        {
            std::stringstream query;

            query <<
                "SELECT COURSES_2.COURSE_ID AS COURSE_ID, COURSES_2.TITLE AS TITLE, COURSES_2.DESCRIPTION AS DESCRIPTION, PRICE, NUMBER_OF_ENROLLS, AVG(RATE) AS RATE\
                    FROM(\
                        SELECT COURSES.COURSE_ID AS COURSE_ID, TITLE, DESCRIPTION, PRICE, COUNT(*) AS NUMBER_OF_ENROLLS\
                        FROM COURSES\
                        JOIN ENROLLED_COURSES\
                        ON(COURSES.COURSE_ID = ENROLLED_COURSES.COURSE_ID)\
                        GROUP BY COURSES.COURSE_ID, TITLE, DESCRIPTION, PRICE\
                    ) COURSES_2\
                    JOIN CONTENTS\
                    ON(COURSES_2.COURSE_ID = CONTENTS.COURSE_ID)\
                    GROUP BY COURSES_2.COURSE_ID, COURSES_2.TITLE, COURSES_2.DESCRIPTION, PRICE, NUMBER_OF_ENROLLS\
                    ORDER BY NUMBER_OF_ENROLLS DESC, RATE DESC";

            std::shared_future<drogon::orm::Result> resultFuture = dbClient.execSqlAsyncFuture(query.str());

            resultFuture.wait();

            drogon::orm::Result result = resultFuture.get();

            std::cout << "Making response" << std::endl;

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
        }
        else if(requestJson["type"].asString() == "get-all-courses")
        {
            
        }

        std::cout << "Sending response" << std::endl;

        drogon::HttpResponsePtr httpResponsePtr = drogon::HttpResponse::newHttpJsonResponse(response);
        callback(httpResponsePtr);
    },
    {drogon::Post});

	httpAppFramework.run();

	return 0;
}