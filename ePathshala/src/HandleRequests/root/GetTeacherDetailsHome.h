#pragma once

#include <iostream>
#include <fstream>
#include <drogon/drogon.h>
#include <drogon/orm/DbClient.h>

void GetTeacherDetailsHome(Json::Value &requestJson, Json::Value &response, drogon::orm::DbClient &dbClient);