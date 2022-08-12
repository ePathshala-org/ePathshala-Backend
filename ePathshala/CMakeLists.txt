cmake_minimum_required(VERSION 3.0.0)
project(ePathshala VERSION 0.1.0)

file(REMOVE_RECURSE ${CMAKE_BINARY_DIR}/sql ${CMAKE_BINARY_DIR}/data)
file(COPY ${CMAKE_SOURCE_DIR}/sql DESTINATION ${CMAKE_BINARY_DIR})
file(COPY ${CMAKE_SOURCE_DIR}/data DESTINATION ${CMAKE_BINARY_DIR})

add_executable(ePathshala
    "src/main.cpp"
    "src/SetupInitData.cpp"
    "src/SetupDbClientPtr.cpp"
    "src/HandleRequests/root/GetUserDetails.cpp"
    "src/HandleRequests/root/GetUserId.cpp"
    "src/HandleRequests/root/GetCoursesPopular.cpp"
    "src/HandleRequests/root/GetCourseContents.cpp"
    "src/HandleRequests/root/GetCourseDetails.cpp"
    "src/HandleRequests/root/GetContentDetails.cpp"
)

find_package(Drogon REQUIRED)
target_link_libraries(ePathshala Drogon::Drogon)