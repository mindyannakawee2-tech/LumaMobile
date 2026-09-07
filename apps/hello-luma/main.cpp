#include <iostream>

#include <Luma/Luma.hpp>


static void printResult(
    const char *name,
    const Luma::Result &result
)
{
    std::cout
        << name
        << ": ";


    if (
        result.ok
    ) {

        std::cout
            << result.value
            << '\n';

    } else {

        std::cout
            << "ERROR "
            << result.status
            << " - "
            << result.error
            << '\n';
    }
}


int main()
{
    std::cout
        << "====================================\n"
        << "        Hello LumaMobile\n"
        << "====================================\n\n";


    Luma::Application app(
        "com.luma.hello"
    );


    printResult(
        "Framework",
        Luma::System::frameworkVersion()
    );


    printResult(
        "Framework ping",
        Luma::System::ping()
    );


    printResult(
        "LMS",
        Luma::Services::version()
    );


    printResult(
        "LMS ping",
        Luma::Services::ping()
    );


    printResult(
        "App registration",
        app.registerWithLMS()
    );


    printResult(
        "Notification",
        Luma::Notifications::post(
            "Hello from the first Luma SDK app"
        )
    );


    std::cout
        << "\nDevice information:\n";


    printResult(
        "Device",
        Luma::Services::deviceInfo()
    );


    return 0;
}
