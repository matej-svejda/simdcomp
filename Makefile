# minimalist makefile
.SUFFIXES:
#
.SUFFIXES: .cpp .o .c .h

# Use -march=corei7 to support SSE4.2 but not AVX: https://gcc.gnu.org/onlinedocs/gcc-4.8.4/gcc/i386-and-x86-64-Options.html
ifeq ($(DEBUG),1)
CFLAGS = -fPIC  -std=c89 -ggdb -march=corei7 -Wall -Wextra -Wshadow -fsanitize=undefined  -fno-omit-frame-pointer -fsanitize=address
else
CFLAGS = -fPIC -std=c89 -O3  -march=corei7 -Wall -Wextra -Wshadow
endif # debug
INSTALL_PREFIX = ./install_x86
LIBNAME=libsimdcomp.a
all:  $(LIBNAME)
test:
	./unit
	./unit_chars
install: $(OBJECTS)
	mkdir -p $(INSTALL_PREFIX)
	mkdir -p $(INSTALL_PREFIX)/lib
	mkdir -p $(INSTALL_PREFIX)/include
	cp $(LIBNAME) $(INSTALL_PREFIX)/lib
	cp $(HEADERS) $(INSTALL_PREFIX)/include



HEADERS=./include/simdbitpacking.h ./include/simdcomputil.h ./include/simdintegratedbitpacking.h ./include/simdcomp.h ./include/simdfor.h ./include/avxbitpacking.h ./include/avx512bitpacking.h ./include/portability.h

uninstall:
	for h in $(HEADERS) ; do rm  /usr/local/$$h; done
	rm  /usr/local/lib/$(LIBNAME)
	rm /usr/local/lib/libsimdcomp.so
	ldconfig


OBJECTS= simdbitpacking.o simdintegratedbitpacking.o simdcomputil.o \
		 simdpackedsearch.o simdpackedselect.o simdfor.o avxbitpacking.o avx512bitpacking.o

$(LIBNAME): $(OBJECTS)
	$(AR) rcs $(LIBNAME) $(OBJECTS)


avx512bitpacking.o: ./src/avx512bitpacking.c $(HEADERS)
	$(CC) $(CFLAGS) -c ./src/avx512bitpacking.c -Iinclude



avxbitpacking.o: ./src/avxbitpacking.c $(HEADERS)
	$(CC) $(CFLAGS) -c ./src/avxbitpacking.c -Iinclude


simdfor.o: ./src/simdfor.c $(HEADERS)
	$(CC) $(CFLAGS) -c ./src/simdfor.c -Iinclude


simdcomputil.o: ./src/simdcomputil.c $(HEADERS)
	$(CC) $(CFLAGS) -c ./src/simdcomputil.c -Iinclude

simdbitpacking.o: ./src/simdbitpacking.c $(HEADERS)
	$(CC) $(CFLAGS) -c ./src/simdbitpacking.c -Iinclude

simdintegratedbitpacking.o: ./src/simdintegratedbitpacking.c  $(HEADERS)
	$(CC) $(CFLAGS) -c ./src/simdintegratedbitpacking.c -Iinclude

simdpackedsearch.o: ./src/simdpackedsearch.c $(HEADERS)
	$(CC) $(CFLAGS) -c ./src/simdpackedsearch.c -Iinclude

simdpackedselect.o: ./src/simdpackedselect.c $(HEADERS)
	$(CC) $(CFLAGS) -c ./src/simdpackedselect.c -Iinclude

example: ./example.c    $(HEADERS) $(OBJECTS)
	$(CC) $(CFLAGS) -o example ./example.c -Iinclude  $(OBJECTS)

unit: ./tests/unit.c    $(HEADERS) $(OBJECTS)
	$(CC) $(CFLAGS) -o unit ./tests/unit.c -Iinclude  $(OBJECTS)

bitpackingbenchmark: ./benchmarks/bitpackingbenchmark.c    $(HEADERS) $(OBJECTS)
	$(CC) $(CFLAGS) -o bitpackingbenchmark ./benchmarks/bitpackingbenchmark.c -Iinclude  $(OBJECTS)
benchmark: ./benchmarks/benchmark.c    $(HEADERS) $(OBJECTS)
	$(CC) $(CFLAGS) -o benchmark ./benchmarks/benchmark.c -Iinclude  $(OBJECTS)
dynunit: ./tests/unit.c    $(HEADERS) $(LIBNAME)
	$(CC) $(CFLAGS) -o dynunit ./tests/unit.c -Iinclude  -lsimdcomp

unit_chars: ./tests/unit_chars.c    $(HEADERS) $(OBJECTS)
	$(CC) $(CFLAGS) -o unit_chars ./tests/unit_chars.c -Iinclude  $(OBJECTS)
clean:
	rm -f unit *.o $(LIBNAME) example benchmark bitpackingbenchmark dynunit unit_chars
