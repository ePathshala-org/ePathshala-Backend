#include "Search.h"

void Search(Json::Value &requestJson, Json::Value &response, drogon::orm::DbClient &dbClient)
{
    std::clog << "Search request" << std::endl;

    if(requestJson["search_type"].asString() == "courses")
    {
        std::clog << "Courses search request" << std::endl;

        std::ifstream inputFileStream("./sql/search/courses/search-result.sql");
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

        std::ifstream inputFileStream("./sql/search/videos/search-result.sql");
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

        std::ifstream inputFileStream("./sql/search/pages/search-result.sql");
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

        std::ifstream inputFileStream("./sql/search/search-result.sql");
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

        std::ifstream inputFileStream("./sql/search/students/search-result.sql");
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

        std::ifstream inputFileStream("./sql/teachers/search-result.sql");
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