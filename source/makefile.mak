#------------------------------------------------------------------------------
!ifndef ROOT
ROOT = $(MAKEDIR)\..
!endif
MAKE = $(ROOT)\bin\make.exe -$(MAKEFLAGS) -f$**
DCC = $(ROOT)\bin\dcc32.exe -Q $**
BRCC = $(ROOT)\bin\brcc32.exe $**


PROJECTS = NetController.exe


default: ..\dcu ..\bin $(PROJECTS) 


..\dcu:
	@if not exist ..\dcu mkdir ..\dcu

..\bin:
	@if not exist ..\bin mkdir ..\bin


NetController.exe: NetController.dpr
	@echo [build NetController.exe]
	$(DCC)

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