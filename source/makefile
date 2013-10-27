#ifndef ROOT
ROOT = $(MAKEDIR)\..
#endif
MAKE = $(ROOT)\bin\make.exe -$(MAKEFLAGS) -f$**
DCC = $(ROOT)\bin\dcc32.exe -Q $**
BRCC = $(ROOT)\bin\brcc32.exe $**


default: ..\dcu ..\bin $(PROJECTS) 


..\dcu:
	@if not exist ..\dcu mkdir ..\dcu

..\bin:
	@if not exist ..\bin mkdir ..\bin



# builds the win32 target
swakeup.mingw:
	gcc -O0 -g3 -Wall -c -fmessage-length=0 -o swakeup.o swakeup.c
	gcc -o ..\bin\swakeup.exe swakeup.o -lws2_32 

# builds the posix style target
swakeup.posix:
	gcc -O0 -g3 -Wall -c -fmessage-length=0 -o swakeup.o swakeup.c
	gcc -o swakeup swakeup.o  
	
# builds the GUI tool
NetController.exe: NetController.dpr
	@echo [build $@]
	$(DCC)


# builds the CLI tool
Wakeup.exe: Wakeup.dpr
	@echo [build $@]
	$(DCC)


# deletes the binary
deltarget : 
	@echo [delete target]
	@echo just in case >> NetController.exe  
	@del NetController.exe    

rebuild : deltarget default

clean : ..\dcu
	@echo [clean dcus]
	@echo removing all dcu files....
	@echo this is a dummy > ..\dcu\dummy.dcu
	@del /S /Q /F ..\dcu\*.dcu > nul
	@echo done


..\doc:
	@if not exist ..\doc mkdir ..\doc
	
docs: ..\doc
	@echo this is a dummy file > ..\doc\dummy.txt
	@del /S /Q /F ..\doc\*.* > nul
	@doxygen 

default: NetController.exe Wakeup.exe swakeup.mingw