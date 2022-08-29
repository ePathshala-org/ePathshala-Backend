#pragma once

#include <iostream>
#include <fstream>
#include <filesystem>
#include <drogon/drogon.h>
#include <drogon/orm/DbClient.h>

void InsertPage(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient, drogon::HttpAppFramework &httpAppFramework);