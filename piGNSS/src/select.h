/*
 * @file select.h
 */


#ifndef SELECT_H
#define SELECT_H

#include <sys/select.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
#include <signal.h>
#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <string.h>
#include <errno.h>
#include <assert.h>


static const int maxstates = 8;

/*!
  @class Select

  @brief Wrapper class for select

  This class allows the creation of select objects which can receive a user defined number
  of file descriptors to watch. The objective is to ease use and readibility

 */
class Select
{
    public:
        static volatile sig_atomic_t gotSignal;

    private:
        int              istate; //!< iterate states
        int              fds[maxstates]; //!< Vector of file descriptors that contain the descriptors to be checked
        int              states[maxstates]; //!< Vector of states to be used when checking the fds
        int              nfds; //!< The total number of saved fds
        int              hfd; //!< Highest-numbered file descriptor in any of the three sets plus one
        fd_set           rd; //!< Set watched to see if data is available for reading from any of its file descriptors
        fd_set           wr; //!< Set watched to see if there is space to write data to any of its file descriptors
        fd_set           er; //!< Set watched to see if "exceptional conditions" occurred
        struct timeval   tv; //!< Struct with timeout (used with select)
        struct timespec  ptv; //!< Struct with timeout values (used with pselect)
        struct sigaction sa; //!<Struct with instructions on how to proceed when receiving a signal
        sigset_t         emptyset; //!< Empty signal mask for pselect
        sigset_t         blockset; //!< Avoids race condition when waiting for a signal in pselect

    public:
        Select();
        Select(int nfd); //!< Constructor for call on select (pselect with null sigmask)
        Select(int nfd, int signum); //!< Constructor for call on pselect to wait for fds and signum
        ~Select();

    public:
        int const getnfds();
        int const getactive();
        int const getfd(int const &pos);
        int const checkfd(int const &pos);
        void      savefd(int fd, int const &pos);
        void      readall();
        void      writeall();
        void      excepall();
        int       waitonselect();
        int       waitonpselect();
        void      wipesets();

        void      setfdread(int const &pos);
        void      setfdwrite(int const &pos);
        void      setfdexcep(int const &pos);

        bool      isfdread(int const &pos);
        bool      isfdwrite(int const &pos);
        bool      isfdexcep(int const &pos);

    private:
        void clearfdread(int fd);
        void clearfdwrite(int fd);
        void clearfdexcep(int fd);

        bool issetfd(int fd, fd_set &set);
        void clearfd(int fd, fd_set &set);
        void setfd(int fd, fd_set &set);
        void zerofd(fd_set &set);
        static void sigHandler(int sig){gotSignal = 1;};
};

#endif /* SELECT_H */
