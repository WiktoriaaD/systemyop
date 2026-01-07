#include <iostream>
#include <fstream>
#include <vector>
#include <thread>
#include <mutex>
#include <cmath>
#include <string>
#include <cctype>

using namespace std;

#define LETTER_COUNT 26


struct Context {
    string content;                  
    unsigned long count[LETTER_COUNT] = {0}; 
    double sumOfSquares = 0;        
    mutex mtx;   
};

//funkcja dla watku
void threads_part(Context& ctx, size_t start, size_t end) {
    //lokalne - dodaje oddzielnie do kazdego prywatnie
    unsigned long local_count[LETTER_COUNT] = {0};
    double local_sum = 0.0;

    for (size_t i = start; i < end; ++i) {
        unsigned char c = ctx.content[i]; //pobranie znaku

        if (isalpha(c)) {
            char lower_c = tolower(c);
            if (lower_c >= 'a' && lower_c <= 'z') {
                local_count[lower_c - 'a']++;
            }
        }

        //pierwiastek  zkodu 
        local_sum += sqrt((double)c);
    }

    lock_guard<mutex> lock(ctx.mtx);
    
    for (int i = 0; i < LETTER_COUNT; ++i) {
        ctx.count[i] += local_count[i];
    }
    ctx.sumOfSquares += local_sum;
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        cout << "Brak pliku" << endl;
        return 1;
    }

    int count_threads = thread::hardware_concurrency(); //domyślnie tyle ile rdzeni
    if (argc >= 3) {
        count_threads = atoi(argv[2]);
    }
    if (count_threads <= 0) count_threads = 4;//zabezpieczenie 

    //wczytywanie
    Context ctx;
    ifstream file(argv[1], ios::binary);
    if (!file) {
        cout << "Nie ma takiego pliku." << endl;
        return 1;
    }

    file.seekg(0, ios::end);    
    size_t size_file = file.tellg();
    file.seekg(0, ios::beg);      

    //wczytanie tresci do - string
    ctx.content.resize(size_file);
    file.read(&ctx.content[0], size_file);
    file.close();

    // threads
    vector<thread> threads;
    size_t part = size_file / count_threads; // Ile bajtów na jeden wątek

    for (int i = 0; i < count_threads; ++i) {
        size_t start = i * part;
        size_t end;

        //ostatni watek - reszta pliku
        if (i == count_threads - 1) {
            end = size_file;
        } else {
            end = start + part;
        }

        // watek tworzony -> do wektora
        // ref(ctx) - oryginał struktury, nie kopia
        threads.push_back(thread(threads_part, ref(ctx), start, end));
    }

    //zakonczenie watkow
    for (auto& t : threads) {
        t.join();
    }

    //wyniki
    cout << "-Wyniki-" << endl;
    for (int i = 0; i < LETTER_COUNT; ++i) {
        cout << (char)('a' + i) << ": " << ctx.count[i] << endl;
    }

    cout << "- Suma: -" << endl;
    cout.precision(10);
    cout << ctx.sumOfSquares << endl;

    return 0;
}
