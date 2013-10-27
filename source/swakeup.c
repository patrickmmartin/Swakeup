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
#include "unistd.h"
#include "string.h"
#include "errno.h"
#include "sys/socket.h"
#include "netinet/in.h"

// TODO need the platform definitions for these
#define SOCKET_ERROR -1
typedef int SOCKET;
#define closesocket(s) close(s)
#endif // WIN32

/**
 * @brief any platform startup actions here
 */
int startup();

/**
 * @brief any platform cleanup actions here
 */
int cleanup();

/**
 * pretty prints the socket related error code if non-zero
 * @param code - the code
 * @param op the operation being attempted
 */
void print_sock_result(int code, const char * op);


const int PHYSADDR_LEN = 6;
const int MAGICPACKET_LEN = 102;


int main(int argc, char * argv[]) {

	print_sock_result(startup(), "startup");

	char MACAddr[] = { 0x00, 0x1D, 0x73, 0x4C, 0x99, 0x2E };

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

	SOCKET Sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_IP);
	if (!Sock) {
		int err;
#ifdef WIN32
		err = WSAGetLastError();
#else
		err = errno;
#endif
		print_sock_result(err, "socket");
	}

	addr.sin_family = AF_INET;
	addr.sin_port = htons(port);
	addr.sin_addr.s_addr = destination_ip;

	// TODO - did not seem to be required on Ubuntu for the broadcast
	// TODO - also root was not required to set this option?
	if (addr.sin_addr.s_addr == INADDR_BROADCAST) {
		sooptval = 1;
		print_sock_result(setsockopt(Sock, SOL_SOCKET, SO_BROADCAST,
						  (void *) &sooptval, sizeof(sooptval)), "setsockopt");
	}

	memset(magicdata, 0xFF, sizeof(magicdata));
	position = PHYSADDR_LEN;
	while (position < sizeof(magicdata)) {
		memcpy(magicdata + position, MACAddr, PHYSADDR_LEN);
		position += PHYSADDR_LEN;
	}
	/* TODO - i don't like the cast to make the warning go away */
	retval = sendto(Sock, magicdata, sizeof(magicdata), 0, (struct sockaddr*) &addr, sizeof(addr));
	if (retval == SOCKET_ERROR)
		print_sock_result(retval, "sendto");
	print_sock_result(closesocket(Sock), "closesocket");

	print_sock_result(cleanup(), "cleanup");
	return 0;
}

void print_sock_result(int code, const char * op) {

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

int startup() {

	int retval = 0;
#ifdef WIN32
	WSADATA wsaData;
	retval = WSAStartup(MAKEWORD(1, 1), &wsaData);
	if (retval)
		print_sock_result(retval, "WSAStartup");
#endif
	return retval;
}

int cleanup() {
#ifdef WIN32
	return WSACleanup();
#else
	return 0;
#endif
}

