#pragma once

#include <fstream>
#include <vector>
#include <drogon/drogon.h>

#if defined WIN32
#include <winsock2.h>
#else
#include <arpa/inet.h>
#endif

void EndDownload(Json::Value &request, Json::Value &response, std::vector<std::pair<std::string, std::fstream>> &downloads, drogon::HttpAppFramework &httpAppFramework);