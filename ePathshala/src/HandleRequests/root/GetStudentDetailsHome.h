#include <iostream>
#include <fstream>
#include <drogon/drogon.h>
#include <drogon/orm/DbClient.h>

void GetStudentDetailsHome(Json::Value &requestJson, Json::Value &response, drogon::orm::DbClient &dbClient);