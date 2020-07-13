#define FILE int
#define wchar char
#define size_t int
typedef int streamsize;

size_t fwrite(const void *ptr, size_t size, size_t nmemb, FILE *stream);
int fputs(const char *s, FILE *stream); 
int fputc(int c, FILE *stream);
int fprintf(FILE *stream, const char *format, ...);
int sprintf(char *s, const char *format, ...);
size_t strlen(const char *s);

namespace std
{
	template<class charT> struct char_traits;

	template <class charT, class traits = char_traits<charT> >
	class basic_ostream /*: virtual public basic_ios<charT,traits> - not needed for this test */ {
	public:
		typedef charT char_type;
		basic_ostream<charT,traits>& write(const char_type* s, streamsize n);
	};

	template <class charT, class traits = char_traits<charT> >
	class basic_ofstream : public basic_ostream<charT,traits> {
	public:
	};

	template<class charT, class traits> basic_ostream<charT,traits>& operator<<(basic_ostream<charT,traits>&, const charT*);

	typedef basic_ostream<char> ostream;
	typedef basic_ofstream<char> ofstream;
};

using namespace std;

char *encrypt(char *buffer) {
  return buffer;
}
char *func(char *buffer) {
  return buffer;
}

// test for CleartextFileWrite
void file() {
  char *theEmail = "cleartext email!";
  FILE *file;

  // BAD: write email to file in cleartext
  fputs(theEmail, file);

  // GOOD: encrypt first
  char *encrypted = encrypt(theEmail);
  fwrite(encrypted, sizeof(encrypted), 1, file);
}

// test for CleartextBufferWrite
int main(int argc, char** argv) {
  char *medical = "medical";
  char *buff1;
  char *buff2;
  char *buff3;
  char *buff4;

  // BAD: write medical to buffer in cleartext
  sprintf(buff1, "%s", medical);

  // BAD: write medical to buffer in cleartext
  char *temp = medical;
  sprintf(buff2, "%s", temp);

  // BAD: write medical to buffer in cleartext
  char *buff5 = func(medical);
  sprintf(buff3, "%s", buff5);

  char *buff6 = encrypt(medical);
  // GOOD: encrypt first
  sprintf(buff4, "%s", buff6); 
}

// test for CleartextFileWrite
void stream() {
  char *theEmail = "cleartext email!";
  ofstream mystream;

  // BAD: write email to file in cleartext
  mystream << "the email is: " << theEmail;

  // BAD: write email to file in cleartext
  (mystream << "the email is: ").write(theEmail, strlen(theEmail));

  // GOOD: encrypt first
  char *encrypted = encrypt(theEmail);
  mystream << "the email is: " << encrypted;
  (mystream << "the email is: ").write(encrypted, strlen(encrypted));
}
