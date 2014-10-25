Swakeup
=======

A "Computer Wrangler" application suite for mainly Windows boxes I wrote a long time ago.
Actually also works with my linux based linkstations (for example).

## Approach
Broadcasts a simple Wake On Lan packet to the local subnet on the port (default 9) with the target MAC.


## Technology

Delphi 7, C


## OS

native Windows 32-bit Intel executables - Windpws XP upwards, and most probably earlier versions

## Deliverables

* NetController.exe - GUI app to harvest  MACs and start/stop/query a list
* Wakeup.exe - command line tool sharing the same code base as NetController.exe
* swakeup - minimal POSIX / mingw + winsock command line tool to Wake On Lan

