/*
 * swakeup.c
 *
 *  Created on: 26 Oct 2013
 *      Author: Patrick
 */

#include "stdio.h"

// includes
#ifdef WIN32
  #include "winsock.h"
#else
  #include "unistd.h"
  #include "string.h"
  #include "errno.h"
  #include "sys/socket.h"
  #include "netinet/in.h"
#endif // WIN32

// platform-specific definitions
#ifdef WIN32
#else
  // standard error for local errors
  #define SOCKET_ERROR -1
  // the standard definition is int for a socket
  typedef int SOCKET;
  #define closesocket(s) close(s)
#endif

/**
 * @brief any platform startup actions here
 * @return non-zero for any startup errors
 */
int sw_startup();

/**
 * @brief any platform cleanup actions here
 * @return non-zero for any shutdown errors
 */
int sw_cleanup();

/**
 * pretty prints the socket related error code if non-zero
 * @param code - the code
 * @param op the operation being attempted
 */
void sw_print_sock_result(int code, const char * op);

/**
 * wraps up returning a unified socket return code
 * @return the platform socket error 
 */
int sw_error();

const int PHYSADDR_LEN = 6;
const int MAGICPACKET_LEN = 102;


int main(int argc, char * argv[]) {

	sw_print_sock_result(sw_startup(), "startup");

	char MACAddr[6];

	/* TODO: parse out the MAC address */
	MACAddr[0] = 0x00;
	MACAddr[1] = 0x1D;
	MACAddr[2] = 0x73;
	MACAddr[3] = 0x4C;
	MACAddr[4] = 0x99;
	MACAddr[5] = 0x2E;

	struct sockaddr_in addr;
	int sooptval;
	int retval;
	int position;
	char magicdata[MAGICPACKET_LEN];
	int destination_ip = 0xffffffff; /* broadcast to all */
	int port = 9;

	SOCKET sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_IP);
	if (!sock) {
                sw_print_sock_result(sw_error(), "socket");
	}

	addr.sin_family = AF_INET;
	addr.sin_port = htons(port);
	addr.sin_addr.s_addr = destination_ip;

	// TODO - did not seem to be required on Ubuntu for the broadcast
	// TODO - also root was not required to set this option?
	if (addr.sin_addr.s_addr == INADDR_BROADCAST) {
		sooptval = 1;
		sw_print_sock_result(setsockopt(sock, SOL_SOCKET, SO_BROADCAST,
						  (void *) &sooptval, sizeof(sooptval)), "setsockopt");
	}

	memset(magicdata, 0xFF, sizeof(magicdata));
	position = PHYSADDR_LEN;
	while (position < sizeof(magicdata)) {
		memcpy(magicdata + position, MACAddr, PHYSADDR_LEN);
		position += PHYSADDR_LEN;
	}

	/* TODO - i don't like the cast to make the warning go away */
	retval = sendto(sock, magicdata, sizeof(magicdata), 0, (struct sockaddr*) &addr, sizeof(addr));
	if (retval == SOCKET_ERROR)
		sw_print_sock_result(retval, "sendto");
	sw_print_sock_result(closesocket(sock), "closesocket");

	sw_print_sock_result(sw_cleanup(), "cleanup");
	return 0;
}

void sw_print_sock_result(int code, const char * op) {

	if (code == 0)
		return;
	char * errorstr = "error message not assigned";

#ifdef WIN32
	FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM,
				  NULL, code, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
				  (LPSTR) errorstr, 0,
				  (va_list*) NULL);
#else
	errorstr = strerror(code);
#endif

	char buffer[1024];
	snprintf(buffer, sizeof(buffer) -1,
			"error in %s - %s", op, errorstr);
	perror(buffer);

}

int sw_startup() {

	int retval = 0;
#ifdef WIN32
	WSADATA wsaData;
	retval = WSAStartup(MAKEWORD(1, 1), &wsaData);
	if (retval)
		sw_print_sock_result(retval, "WSAStartup");
#endif
	return retval;
}

int sw_cleanup() {
#ifdef WIN32
	return WSACleanup();
#else
	return 0;
#endif
}

int sw_error()
{
#ifdef WIN32
  return WSAGetLastError();
#else
  return errno;
#endif
}
