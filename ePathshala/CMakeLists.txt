cmake_minimum_required(VERSION 3.0.0)
project(ePathshala VERSION 0.1.0)

add_executable(ePathshala
    "src/main.cpp"
    "src/SetupInitData.cpp"
    "src/SetupDbClientPtr.cpp"
    "src/HandleRequests/root/CreateNewAccount.cpp"
    "src/HandleRequests/root/GetStudentAllCourses.cpp"
    "src/HandleRequests/root/GetStudentCourses.cpp"
    "src/HandleRequests/root/GetStudentDetailsHome.cpp"
    "src/HandleRequests/root/GetTeacherCourses.cpp"
    "src/HandleRequests/root/GetTeacherDetailsHome.cpp"
    "src/HandleRequests/root/InitNotLoggedIn.cpp"
    "src/HandleRequests/root/Login.cpp"
    "src/HandleRequests/root/Search.cpp"
    "src/HandleRequests/root/GetContents.cpp"
)

find_package(Drogon REQUIRED)
target_link_libraries(ePathshala Drogon::Drogon)

file(REMOVE_RECURSE ${CMAKE_BINARY_DIR}/sql ${CMAKE_BINARY_DIR}/data)
file(COPY ${CMAKE_SOURCE_DIR}/sql DESTINATION ${CMAKE_BINARY_DIR})
file(COPY ${CMAKE_SOURCE_DIR}/data DESTINATION ${CMAKE_BINARY_DIR})