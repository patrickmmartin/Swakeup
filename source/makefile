#ifndef ROOT
ROOT = $(MAKEDIR)\..
#endif
MAKE = $(ROOT)\bin\make.exe -$(MAKEFLAGS) -f$**
DCC = $(ROOT)\bin\dcc32.exe -Q $*
BRCC = $(ROOT)\bin\brcc32.exe $**


default: ..\dcu ..\bin $(PROJECTS) 

# creates the dir if required
..\dcu:
	@if not exist ..\dcu mkdir ..\dcu

# creates the dir if required
..\bin:
	@if not exist ..\bin mkdir ..\bin

# creates the dir if required
..\obj:
	@if not exist ..\obj mkdir ..\obj
# creates the dir if required
../obj:
	@mkdir -p ../obj

# creates the dir if required
../bin:
	@mkdir -p ../bin

# builds the win32 target
swakeup.mingw: ..\obj ..\bin
	@echo [build $@]
	gcc -O0 -g3 -Wall -c -fmessage-length=0 -o ..\obj\swakeup.o swakeup.c
	gcc -o ..\bin\swakeup.exe ..\obj\swakeup.o -lws2_32 

# builds the posix style target
swakeup.posix: ../obj ../bin
	@echo [build $@]
	gcc -O0 -g3 -Wall -c -fmessage-length=0 -o ../obj/swakeup.o swakeup.c
	gcc -o ../bin/swakeup ../obj/swakeup.o  

# builds the GUI tool
NetController.exe: NetController.dpr 
	@echo [build $@]
	$(DCC)


# builds the CLI tool
Wakeup.exe: Wakeup.dpr 
	@echo [build $@]
	$(DCC)


# deletes the GUI binary
deltarget : 
	@echo [delete target]
	@echo just in case >> NetController.exe  
	@del NetController.exe    

# deletes and rebuilds
rebuild : deltarget default

# cleans the dcus
clean : ..\dcu
	@echo [clean dcus]
	@echo removing all dcu files....
	@echo this is a dummy > ..\dcu\dummy.dcu
	@del /S /Q /F ..\dcu\*.dcu > nul
	@echo done

# creates the dir if required
..\doc:
	@if not exist ..\doc mkdir ..\doc

# builds the doxygen target
docs: ..\doc
	@echo this is a dummy file > ..\doc\dummy.txt
	@del /S /Q /F ..\doc\*.* > nul
	@doxygen 

# builds the Windows suite of binaries
default: NetController.exe Wakeup.exe swakeup.mingw


#lints the c file
lint:
	splint +posixlib +gnuextensions -I /usr/include/x86_64-linux-gnu swakeup.c
