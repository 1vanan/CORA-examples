#
# compiler
#
#CC        = g++
CC       	  = clang++
CXXFLAGS 		= -Wall -Wextra -std=c++11 -O3 -DNDEBUG
CXXDEBUG		= -g -Wall -Wextra -std=c++11 
#
# scots 
#
SCOTSROOT		= ../..
SCOTSINC		= -I$(SCOTSROOT)/src -I$(SCOTSROOT)/utils

.PHONY: oneShot

TARGET = oneShot

all: $(TARGET)

oneShot:
	$(CC) $(CXXFLAGS) $(SCOTSINC) oneShotTank.cc -o oneShotTank

clean:
	rm oneShotTank
