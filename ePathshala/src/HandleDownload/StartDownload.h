#pragma once

#include <fstream>
#include <json/json.h>
#include <drogon/drogon.h>

void StartDownload(Json::Value &request, Json::Value &response, std::vector<std::pair<std::string, std::fstream>> &downloads, drogon::HttpAppFramework &httpAppFramework);