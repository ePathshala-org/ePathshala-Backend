#pragma once

#include <fstream>
#include <vector>
#include <json/json.h>

void ContinueDownload(Json::Value &request, Json::Value &response, std::vector<std::pair<std::string, std::fstream>> &downloads);