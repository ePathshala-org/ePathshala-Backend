#pragma once

#include <iostream>
#include <drogon/drogon.h>
#include <drogon/orm/DbClient.h>

void InsertTeacher(Json::Value &request, drogon::orm::DbClient &dbClient);