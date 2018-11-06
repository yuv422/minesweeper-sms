/* A quick port of the C# usb-tool for the master everdrive        */
/* This only does game upload. It doesn't support firmware uploads */
/* Eric Fry                                                        */
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <termios.h>

int open_port(char *device)
{
  int fd;

}

int sendGame(int fd, char *file)
{
  unsigned char *buf;
  long size = 0;
  long alloc_size = 0;
  long i;
  int j;
  FILE *f = NULL;
  char ack;
  unsigned char num_blocks;

  f = fopen(file, "r");
  if(f == NULL)
  {
    printf("Cannot open file.\n");
    return 0;
  }

  fseek(f, 0, SEEK_END);
  size = ftell(f);
  fseek(f, 0, SEEK_SET);

  if(size % 1024 == 512)
  {
    fseek(f, 512, SEEK_SET);
    size -= 512;
  }

  if(size % 65536 != 0)
  {
    alloc_size = size / 65536 * 65536 + 65536;
  }
  else
  {
    alloc_size = size;
  }

  buf = (unsigned char *)malloc(alloc_size);
  memset(buf, 0, alloc_size);

  fread(buf, 1, size, f);

  fclose(f);

  write(fd, "+g", 2);
  num_blocks = (unsigned char)(alloc_size / 65536);
  write(fd, &num_blocks, 1);

  read(fd, &ack, 1);

  if(ack != 'k')
  {
    return 0;
  }
  printf("erase.\n");


  printf("write.\n");

  j=0;
  for(i=0;i < alloc_size;i += 32768)
  {
    write(fd, &buf[i], 32768);
    read(fd, &ack, 1);

    if(ack != 'k')
    {
      return 0;
    }
    printf("%d\n", j);
    j += 32;
  }

  printf("done.\n");
  return 1;
}

int main(int argc, char **argv)
{
  int fd;
  struct termios oldtio, newtio;

  if(argc != 3)
  {
    printf("\nMaster Everdrive Usb-loader.\nUsage:\n%s <serial_port_device> <rom_filename>\n\n",argv[0]);
    return 1;
  }

  fd = open(argv[1], O_RDWR | O_NOCTTY);
  if(fd == -1)
  {
    printf("Error opening serial port.\n");
    return 1;
  }

  tcgetattr(fd,&oldtio); /* save current serial port settings */
  bzero(&newtio, sizeof(newtio)); /* clear struct for new port settings */

  newtio.c_cflag = 921600 | CRTSCTS | CS8 | CLOCAL | CREAD;

  newtio.c_cc[VTIME]    = 0;   /* inter-character timer unused */
  newtio.c_cc[VMIN]     = 1;   /* blocking read until 1 chars received */

  tcflush(fd, TCIFLUSH);
  tcsetattr(fd,TCSANOW,&newtio);

  write(fd, "USBm+t", 6);
  char ack;

  read(fd, &ack, 1);
  if(ack == 'k')
    printf("Connected...\n");

  if(sendGame(fd, argv[2]) == 0)
  {
    printf("Error sending rom!\n");
  }
  tcsetattr(fd,TCSANOW,&oldtio);

  return 0;
}
