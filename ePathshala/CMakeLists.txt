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
    "src/HandleRequests/root/GetComments.cpp"
    "src/HandleRequests/root/GetStudentDetails.cpp"
    "src/HandleRequests/root/GetCoursesStudent.cpp"
    "src/HandleRequests/root/GetCourseRemainContentCount.cpp"
    "src/HandleRequests/root/CheckStudentEnrolled.cpp"
    "src/HandleRequests/root/BuyCourse.cpp"
    "src/HandleRequests/root/GetCoursesTeacher.cpp"
    "src/HandleRequests/root/GetTeacherDetails.cpp"
    "src/HandleRequests/root/UpdateUserDetails.cpp"
    "src/HandleRequests/root/UpdatePfp.cpp"
    "src/HandleRequests/root/Insert/Course.cpp"
    "src/HandleRequests/root/Insert/Comment.cpp"
    "src/HandleRequests/root/Delete/Comment.cpp"
    "src/HandleRequests/root/Update/CommentRate.cpp"
    "src/HandleRequests/root/Update/Comment.cpp"
    "src/HandleRequests/root/GetInterests.cpp"
    "src/HandleRequests/root/Delete/Interest.cpp"
    "src/HandleRequests/root/Insert/Teacher.cpp"
    "src/HandleRequests/root/Insert/Student.cpp"
    "src/HandleRequests/root/Insert/Interest.cpp"
    "src/HandleRequests/root/Delete/Course.cpp"
    "src/HandleRequests/root/GetSpecialities.cpp"
    "src/HandleRequests/root/Insert/Speciality.cpp"
    "src/HandleRequests/root/Delete/Speciality.cpp"
    "src/HandleRequests/root/Delete/Content.cpp"
    "src/HandleRequests/root/Update/Course.cpp"
    "src/HandleRequests/root/Upload/Video.cpp"
    "src/HandleRequests/root/Update/Video.cpp"
    "src/HandleRequests/root/Insert/User.cpp"
    "src/HandleRequests/root/Login.cpp"
    "src/HandleRequests/root/Insert/Question.cpp"
    "src/HandleRequests/root/GetQuestions.cpp"
)

find_package(Drogon REQUIRED)
target_link_libraries(ePathshala Drogon::Drogon)
find_package(ImageMagick COMPONENTS Magick++)
include_directories(${ImageMagick_INCLUDE_DIRS})
target_link_libraries(ePathshala ${ImageMagick_LIBRARIES})