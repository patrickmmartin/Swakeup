/*
 * swakeup.c
 *
 *  Created on: 26 Oct 2013
 *      Author: Patrick
 */

#include "stdio.h"
#include "libgen.h"

// includes
#ifdef WIN32
  #include "winsock.h"
  #include "stdint.h"
#else
  #ifndef S_SPLINT_S
  #include "unistd.h"
  #include "stdlib.h"
  #include "string.h"
  #include "errno.h"
  #include "sys/socket.h"
  #include "netinet/in.h"
  #endif
#endif // WIN32

// platform-specific definitions
#ifdef WIN32
  typedef int in_addr_t;
  typedef size_t socklen_t; 
  typedef int sa_family_t;
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
static int sw_startup();

/**
 * @brief any platform cleanup actions here
 * @return non-zero for any shutdown errors
 */
static int sw_cleanup();

/**
 * pretty prints the socket related error code if non-zero
 * @param code - the code
 * @param op the operation being attempted
 */
static void sw_print_sock_result(int code, const char * op);

/**
 * wraps up returning a unified socket return code
 * @return the platform socket error 
 */
static int sw_error();

static const size_t PHYSADDR_LEN = 6;
static const int MAGICPACKET_LEN = 102;

#define usagestr  "%s\n" \
				  "usage\n" \
				  "%s macaddress\n" \
				  "macaddress in format aa:bb:cc:dd:ee:ff or aa-bb-cc-dd-ee-ff\n" \
				  "sends a WOL packet to the local broadcast address on port 9"


static const char PATH_SEP =
#ifdef WIN32
                            '\\';
#else
                            '/';
#endif				  

static void usage(char * arg0, char * reason)
{
    // splint complained about basename and strdup
	char * filename = arg0;
	char * filesep = strrchr(filename, PATH_SEP);
	if (filesep)
		filename = filesep++;
	printf(usagestr, reason, filename);
}

int main(int argc, char * argv[]) {

	unsigned char MACAddr[6] = {(unsigned char) 0, 
								(unsigned char) 0, 
								(unsigned char) 0, 
								(unsigned char) 0, 
								(unsigned char) 0, 
								(unsigned char) 0};

	char *token;
	char *search = ":-";
	size_t i;
	
	struct sockaddr_in addr;
	int sooptval;
	ssize_t retval;
	size_t position;
	char magicdata[MAGICPACKET_LEN];
	in_addr_t destination_ip = (in_addr_t) 0xffffffff; /* broadcast to all */
	uint16_t port = 9;
	SOCKET sock;
	
	if (argc != 2)
	{
		usage(argv[0], "invalid argument count");
		return -1;
	}
	
	i = 0;
	token = strtok(argv[1], search);

	if (token)
	{
		MACAddr[i] = (unsigned char) strtol(token, NULL, 16);
		i++;

		while (	(token = strtok(NULL, search) ) )
		{
			if ( i < PHYSADDR_LEN)
				MACAddr[i] = (unsigned char) strtol(token, NULL, 16);
			i++;
		}
	}
	
	if (i != PHYSADDR_LEN)
	{
		usage(argv[0], "invalid MAC address");
		return -1;
	}
	
	sw_print_sock_result(sw_startup(), "startup");

	sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_IP);
	if (sock == 0) {
                sw_print_sock_result(sw_error(), "socket");
	}

	addr.sin_family = (sa_family_t) AF_INET;
	addr.sin_port = htons(port);
	addr.sin_addr.s_addr = destination_ip;

	// TODO - did not seem to be required on Ubuntu for the broadcast
	// TODO - also root was not required to set this option?
	if (addr.sin_addr.s_addr == INADDR_BROADCAST) {
		sooptval = 1;
		sw_print_sock_result(setsockopt(sock, SOL_SOCKET, SO_BROADCAST,
						  (void *) &sooptval, sooptval), "setsockopt");
	}

	memset(magicdata, 0xFF, sizeof(magicdata));
	position = PHYSADDR_LEN;
	while (position < sizeof(magicdata)) {
		memcpy(magicdata + position, MACAddr, PHYSADDR_LEN);
		position += PHYSADDR_LEN;
	}

	/* TODO - i don't like the cast to make the warning go away */
	retval = sendto(sock, magicdata, sizeof(magicdata), 0, (struct sockaddr*) &addr, (int) sizeof(addr));
	if (retval == SOCKET_ERROR)
		sw_print_sock_result(SOCKET_ERROR, "sendto");
	sw_print_sock_result(closesocket(sock), "closesocket");

	sw_print_sock_result(sw_cleanup(), "cleanup");
	return 0;
}

static void sw_print_sock_result(int code, const char * op) {

	if (code == 0)
		return;
		
	perror(op);
}

static int sw_startup() {

	int retval = 0;
#ifdef WIN32
	WSADATA wsaData;
	retval = WSAStartup(MAKEWORD(1, 1), &wsaData);
	if (retval)
		sw_print_sock_result(retval, "WSAStartup");
#endif
	return retval;
}

static int sw_cleanup() {
#ifdef WIN32
	return WSACleanup();
#else
	return 0;
#endif
}

static int sw_error()
{
#ifdef WIN32
  return WSAGetLastError();
#else
  return errno;
#endif
}
