#pragma once

#include <iostream>
#include <string>
#include <drogon/drogon.h>
#include <drogon/orm/DbClient.h>

void GetStudentDetails(Json::Value &request, Json::Value &response, drogon::orm::DbClient &dbClient);