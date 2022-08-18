#include "UpdatePfp.h"

void UpdatePfp(Json::Value &request, Json::Value &response, drogon::HttpAppFramework &httpAppFramework)
{
    std::clog << "Update \"pfp\"request" << std::endl;

    std::string user_id = request["user_id"].asString();
    std::string docRoot = httpAppFramework.getDocumentRoot();
    std::ofstream tempFile(docRoot + "/temp/" + user_id + "_temp_pfp.png", std::ios_base::openmode::_S_out | std::ios_base::openmode::_S_bin);

    for(size_t i = 0; i < request["file_data_array"].size(); ++i)
    {
        uint8_t toWrite = request["file_data_array"].get(i, Json::Int(0)).asInt();

        tempFile << toWrite;
    }

    tempFile.close();

    Magick::Image pfp(docRoot + "/temp/" + user_id + "_temp_pfp.png");

    if(pfp.size().width() != pfp.size().height() || pfp.size().width() > 96 || pfp.size().height() > 96)
    {
        response["pfp_updated"] = false;
    }
    else
    {
        std::ifstream tempFile(docRoot + "/temp/" + user_id + "_temp_pfp.png", std::ios_base::openmode::_S_in | std::ios_base::openmode::_S_bin);
        std::ofstream pfpFile(docRoot + "/pfp/" + user_id + ".png", std::ios_base::openmode::_S_out | std::ios_base::openmode::_S_bin);

        pfpFile << tempFile.rdbuf();

        pfpFile.close();
        tempFile.close();
        remove((docRoot + "/temp/" + user_id + "_temp_pfp.png").c_str());

        response["pfp_updated"] = true;
    }

    response["ok"] = true;
}