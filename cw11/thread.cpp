#include <iostream>
#include <vector>
#include <cmath>
#include <thread>
#include <cstring>
// Biblioteki systemowe Linuxa -- opcjonalnie
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <pthread.h>


using namespace std;

struct SharedData {
    pthread_mutex_t mutex;   
    unsigned int letters[26]; 
    double sqrtSum;         
};

int main(int argc, char* argv[]) {

    if (argc < 2) {
        cerr << "Uzycie: " << argv[0] << " <plik> [ilosc_procesow]" << endl;
        return 1;
    }

    const char* filepath = argv[1];
    

    int numProcesses = thread::hardware_concurrency();
    if (argc >= 3) {
        try {
            numProcesses = stoi(argv[2]);
        } catch (...) {
            numProcesses = 4;
        }
    }
    if (numProcesses < 1) numProcesses = 1;


    int fd = open(filepath, O_RDONLY);
    if (fd == -1) {
        perror("Blad otwarcia pliku"); 
        return 1;
    }

    struct stat sb;
    if (fstat(fd, &sb) == -1) {
        perror("Blad fstat");
        close(fd);
        return 1;
    }
    size_t fileSize = sb.st_size;

    char* fileData = (char*)mmap(NULL, fileSize, PROT_READ, MAP_PRIVATE, fd, 0);
    if (fileData == MAP_FAILED) {
        perror("Blad mmap pliku");
        close(fd);
        return 1;
    }

    SharedData* shared = (SharedData*)mmap(NULL, sizeof(SharedData), 
    PROT_READ | PROT_WRITE, 
    MAP_SHARED | MAP_ANONYMOUS, -1, 0);
    if (shared == MAP_FAILED) {
        perror("Blad mmap pamieci wspoldzielonej");
        munmap(fileData, fileSize);
        close(fd);
        return 1;
    }

    //zerowanie pamieci
    memset(shared->letters, 0, sizeof(shared->letters));
    shared->sqrtSum = 0.0;

    
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_setpshared(&attr, PTHREAD_PROCESS_SHARED);
    pthread_mutex_init(&shared->mutex, &attr);
    pthread_mutexattr_destroy(&attr);

    //fork - klonowanie procesow
    size_t chunkSize = fileSize / numProcesses;

    for (int i = 0; i < numProcesses; ++i) {
        pid_t pid = fork(); //program sie rozdwaja

        if (pid == 0) { 
            
            size_t start = i * chunkSize;
            //ostatni beirze wszystko od poczatku do konca
            size_t end = (i == numProcesses - 1) ? fileSize : start + chunkSize;

            //lokalnie
            unsigned int localLetters[26] = {0};
            double localSqrtSum = 0.0;

            for (size_t j = start; j < end; ++j) {
                unsigned char c = fileData[j];

                localSqrtSum += sqrt((double)c);

                //literki
                if (c >= 'A' && c <= 'Z') {
                    localLetters[c - 'A']++;
                } else if (c >= 'a' && c <= 'z') {
                    localLetters[c - 'a']++;
                }
            }

          //blokada mutexa
            pthread_mutex_lock(&shared->mutex);
            for (int k = 0; k < 26; ++k) {
                shared->letters[k] += localLetters[k];
            }
            shared->sqrtSum += localSqrtSum;
            pthread_mutex_unlock(&shared->mutex);

            exit(0); 
        } else if (pid < 0) {
            perror("Blad fork");
        }
    }

    for (int i = 0; i < numProcesses; ++i) {
        wait(NULL);
    }

    //wyniki
    cout << "--- Wyniki ---" << endl;
    for (int i = 0; i < 26; ++i) {
        cout << (char)('a' + i) << ": " << shared->letters[i] << endl;
    }
    cout.precision(10);
    cout << "Suma pierwiastkow ASCII: " << shared->sqrtSum << endl;

    //sprzatanie
    pthread_mutex_destroy(&shared->mutex);
    munmap(shared, sizeof(SharedData));
    munmap(fileData, fileSize);
    close(fd);

    return 0;
}
