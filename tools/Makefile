CC = gcc

SRCS = $(wildcard *.c)

all: $(SRCS:.c=.c.out)

%.c.out: %.c
	$(CC) $< -o $@

clean:
	rm -f $(SRCS:.c=.c.out)
