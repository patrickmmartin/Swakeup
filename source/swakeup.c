/*
 * wakeup.c
 *
 *  Created on: 26 Oct 2013
 *      Author: Patrick
 */

#include "stdio.h"

#ifdef WIN32
  #include "winsock.h"
#else
  #include "string.h"
  #include "errno.h"
  #include "sys/socket.h"
  #include "netinet/in.h"

#endif

#define SOCKET_ERROR -1

typedef int SOCKET;

void check_sock_result(int code, const char * op)
{

  char * buffer = "not assigned";

#ifdef WIN32
	if (!code)
		return;
  FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER|FORMAT_MESSAGE_FROM_SYSTEM,
                            NULL,
                            code,
                            MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                            (LPSTR) buffer,
                            0,
                            (va_list*) NULL );
#else
  /* TODO */
	if (!code)
		return;
	buffer = strerror(code);

#endif

  printf("error message in %s \n %s\n", op, buffer);

}


int startup()
{

int retval = 0;
#ifdef WIN32		
	WSADATA wsaData;
	retval = WSAStartup( MAKEWORD(1, 1), &wsaData), "WSAStartup");
	if (retval)
		check_sock_result(retval);
#endif
  return retval;
}

int cleanup()
{
#ifdef WIN32
	return WSACleanup();
#else
	return 0;
#endif
}


#ifndef WIN32
  #define closesocket(s) close(s)
#endif

int main(int argc, char * argv[])
{

	startup();

	const int PHYSADDR_LEN = 6;
	const int MAGICPACKET_LEN = 102;

	char MACAddr[] = {0x00, 0x1D, 0x73, 0x4C, 0x99, 0x2E} ;

	/* TODO: parse out the MAC address */
	MACAddr[0] = 0x00;
	MACAddr[1] = 0x1D;
	MACAddr[2] = 0x73;
	MACAddr[3] = 0x4C;
	MACAddr[4] = 0x99;
	MACAddr[5] = 0x2E;

	struct sockaddr_in Addr;
	int  OptVal;
	int  RetVal;
	int  Position;
	char MagicData[MAGICPACKET_LEN];
	int IP = 0xffffffff;  /* broadcast to all */
	int Port = 9;

	SOCKET Sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_IP);
	if (!Sock)
	{
		int err;
		#ifdef WIN32
		err = WSAGetLastError();
		#else
		err = errno;
		#endif
		check_sock_result(err, "socket");
	}


	Addr.sin_family = AF_INET;
    Addr.sin_port = htons(Port);
    Addr.sin_addr.s_addr = IP;

    // TODO - did not seem to be required on Ubuntu
    if (Addr.sin_addr.s_addr == INADDR_BROADCAST)
    {
      OptVal = 1;
      check_sock_result(setsockopt(Sock, SOL_SOCKET, SO_BROADCAST,
                         (void *) &OptVal, sizeof(OptVal)), "setsockopt");
    }

    memset(MagicData, 0xFF, sizeof(MagicData));
    Position = PHYSADDR_LEN;
    while (Position < sizeof(MagicData))
    {
      memcpy(MagicData + Position, MACAddr, PHYSADDR_LEN);
      Position += PHYSADDR_LEN;
    }
    /* TODO - i don't like the cast to make the warning go away */
    RetVal = sendto(Sock, MagicData, sizeof(MagicData), 0, (struct sockaddr*) &Addr, sizeof(Addr));
    if (RetVal == SOCKET_ERROR)
      check_sock_result(RetVal, "sendto");
    check_sock_result(closesocket(Sock), "closesocket");

	return cleanup();
}

