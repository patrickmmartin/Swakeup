#ifndef ROOT
ROOT = $(MAKEDIR)\..
#endif
MAKE = $(ROOT)\bin\make.exe -$(MAKEFLAGS) -f$**
DCC = $(ROOT)\bin\dcc32.exe -Q $*
BRCC = $(ROOT)\bin\brcc32.exe


# this is an override of the default implicit rule for  ".dpr.exe" 
# to override the default .dpr.exe rule
.dpr.exe: 
	@echo [build $@]
	@buildkeys $@
	$(BRCC) $&.rcscript
	$(DCC) 



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


swakeupicon.res: swakeupicon.rc
	$(BRCC) $&.rc

# builds the win32 target
swakeup.mingw: ..\obj ..\bin
	@echo [build $@]
	@buildkeys
	windres -i swakeup.rcscript -o ..\obj\swakeuprc.o
	windres -i swakeupicon.rc -o ..\obj\swakeupicon.o
	gcc -O0 -g3 -Wall -c -fmessage-length=0 -o ..\obj\swakeup.o swakeup.c
	gcc -o ..\bin\swakeup.exe ..\obj\swakeuprc.o ..\obj\swakeupicon.o ..\obj\swakeup.o -lws2_32 

# builds the posix style target
swakeup.posix: ../obj ../bin
	@echo [build $@]
	gcc -O0 -g3 -Wall -c -fmessage-length=0 -o ../obj/swakeup.o swakeup.c
	gcc -o ../bin/swakeup ../obj/swakeup.o  

# builds the GUI tool
NetController.exe: ..\dcu ..\bin swakeupicon.res

# builds the CLI tool
Wakeup.exe:  ..\dcu ..\bin swakeupicon.res


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
	splint +posixlib -I /usr/include/x86_64-linux-gnu swakeup.c
