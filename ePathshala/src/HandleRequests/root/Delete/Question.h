#pragma once

#include <iostream>
#include <drogon/drogon.h>
#include <drogon/orm/DbClient.h>

void DeleteQuestion(Json::Value &request, drogon::orm::DbClient &dbClient, drogon::HttpAppFramework &httpAppFramework);