//! @file select.h

#include "select.h"
#include "debug/debug.h"

volatile sig_atomic_t Select::gotSignal = 0;

Select::Select(){};


Select::Select(int nfds):nfds(nfds){
	#ifdef TRACE
	T(std::cout,  "Enters Select::Select");
	#endif
	
	hfd = 0;
	FD_ZERO(&rd);
	FD_ZERO(&wr);
	FD_ZERO(&er);
	
	tv.tv_sec   =0;
	tv.tv_usec  =0;
	ptv.tv_sec  =0;
	ptv.tv_nsec =0;
	
	istate  = 0;
	std::fill(fds,fds+maxstates,-1);
	std::fill(states,states+maxstates,-1);
	
	//Does nothing
	sigemptyset(&blockset);
	sigemptyset(&emptyset);
	
	#ifdef VALIDATION
	int fd = 0;
	setfd(fd,rd);
	setfd(fd,wr);
	setfd(fd,er);

	assert(issetfd(fd,rd));
	assert(issetfd(fd,wr));
	assert(issetfd(fd,er));
	assert(hfd==fd);
	
	clearfd(fd,rd);
	clearfd(fd,wr);
	clearfd(fd,er);
	assert(!issetfd(fd,rd));
	assert(!issetfd(fd,wr));
	assert(!issetfd(fd,er));
	#endif
	
	
}



/**
 * @brief Prepares a call on pselect, where signum is listened for
 * 
 * This constructor constructs a pselect car that avoids race conditions
 * with the signum that is being listened. If the signum is set to -1,
 * then no signal is added to the signal set.
 * 
 */
Select::Select(int nfds, int signum):nfds(nfds){
	#ifdef TRACE
	T(std::cout, "Enters Select::Select for pselect");
	#endif
	#ifdef DEBUG_SEL
	D(std::cout, nfds);
	#endif
	
	hfd = 0;
	FD_ZERO(&rd);
	FD_ZERO(&wr);
	FD_ZERO(&er);
	
	tv.tv_sec   = 0;
	tv.tv_usec  = 0;
	ptv.tv_sec  = 0;
	ptv.tv_nsec = 0;
	
	istate  = 0;
	std::fill(fds,fds+maxstates,-1);
	std::fill(states,states+maxstates,-1);
	
	
	/// \todo change to empty set
	// if singnum is -1, then no sig is added
	
	// Block $SIGNUM in order to avoid race condition
	sigemptyset(&blockset);
	
	if(signum!=-1){
		sigaddset(&blockset, signum); 
		if(sigprocmask(SIG_BLOCK, &blockset, NULL)==-1){
			std::cerr << strerror(errno) << std::endl;
			exit(EXIT_FAILURE);
		};

		// Establish signal handler
		sa.sa_flags   = 0;
		sa.sa_handler = sigHandler;
		sigemptyset(&sa.sa_mask);
		if(sigaction(signum, &sa, NULL)){
			std::cerr << strerror(errno) << std::endl;
			exit(EXIT_FAILURE);
		};
	}
	sigemptyset(&emptyset);
	
	#ifdef VALIDATION
	int fd = 0;
	setfd(fd,rd);
	setfd(fd,wr);
	setfd(fd,er);
	
	assert(issetfd(fd,rd));
	assert(issetfd(fd,wr));
	assert(issetfd(fd,er));
	assert(hfd==fd);
	
	clearfd(fd,rd);
	clearfd(fd,wr);
	clearfd(fd,er);
	assert(!issetfd(fd,rd));
	assert(!issetfd(fd,wr));
	assert(!issetfd(fd,er));
	#endif
}


Select::~Select(){
	#ifdef TRACE
	T(std::cout,  "Enters Select::~Select");
	#endif
	
	for(int i=0;i<maxstates;i++){
		if(fds[i]>0){
			::close(fds[i]);
		}
	}
	
}


void Select::savefd(int fd, int const &pos){
	#ifdef TRACE
	T(std::cout,  "Enters Select::savefd");
	#endif
	#ifdef DEBUG_SEL
	D(std::cout,nfds);
	D(std::cout,fd);
	D(std::cout,pos);
	D(std::cout,istate);
	assert(pos<maxstates);
	#endif
	fds[pos]		 = fd;
	states[istate++] = pos;
}

int const Select::getnfds(){
	return nfds;
}

int const Select::getactive(){
	return istate;
}

int const Select::getfd(int const &pos){
	#ifdef TRACE
	T(std::cout, "Enters Select::getfd");
	#endif
	#ifdef DEBUG_SEL
	D(std::cout,nfds);
	D(std::cout,pos);
	assert(pos<maxstates);
	#endif
	return fds[pos];
}

int const Select::checkfd(int const &pos){
	#ifdef TRACE
	T(std::cout, "Enters Select::checkfd");
	#endif
	#ifdef DEBUG_SEL
	D(std::cout, pos);
	D(std::cout, states[pos]);
	D(std::cout, fds[states[pos]]);
	#endif
	int state = -1;
	bool rf,wf,ef = false;
	
	if(fds[states[pos]]!=-1){
		rf = issetfd(fds[states[pos]],rd);
		wf = issetfd(fds[states[pos]],wr);
		ef = issetfd(fds[states[pos]],er);

		if(rf || wf || ef){
			#ifdef DEBUG_SEL
			D(std::cout, rf);
			D(std::cout, wf);
			D(std::cout, ef);
			for(int i = 0; i< maxstates; i++)
				D(std::cout, states[i]);
			#endif
			
			state = states[pos];
		}
		else{
			#ifdef DEBUG_SEL
			P(std::cout, "Select::checkfd not set");
			#endif
			state = -1;
		}
	}
	#ifdef DEBUG_SEL
	D(std::cout, state);
	#endif
	return state;
}



//! Removes the given descriptor from the correspondig set
void Select::clearfd(int fd, fd_set &set){
	#ifdef TRACE
	T(std::cout,  "Enters Select::clearfd");
	#endif
	
	FD_CLR(fd, &set);
	hfd = 0;
	
	// \todo need to reset state vector
	
	#ifdef VALIDATION
	assert(!issetfd(fd,set));
	#endif
}

//! Checks if the descriptor is set
bool Select::issetfd(int fd, fd_set &set){
	#ifdef TRACE
	T(std::cout,  "Enters Select::issetfd");
	#endif
	int r = 0;
	r = FD_ISSET(fd,&set);
	return r!=0?true:false;
}

//! Starts watching the descriptor
void Select::setfd(int fd, fd_set &set){
	#ifdef TRACE
	T(std::cout,  "Enters Select::setfd");
	#endif
	
	FD_SET(fd,&set);
	hfd = (hfd > fd)?hfd:fd;
	
	#ifdef VALIDATION
	assert(issetfd(fd,set));
	#endif
}

//! Clears the entire set
void Select::zerofd(fd_set &set){
	#ifdef TRACE
	T(std::cout,  "Enters Select::zerofd");
	#endif
	FD_ZERO(&set);
}

//! Clears all sets
void Select::wipesets(){
	#ifdef TRACE
	T(std::cout,  "Enters Select::wipesets");
	#endif
	zerofd(rd);
	zerofd(wr);
	zerofd(er);
}


//! Sets read watch on all descriptors
void Select::readall(){
	#ifdef TRACE
	T(std::cout, "Enters Select::readall");
	#endif
	for(int i=0;i<maxstates;i++){
		setfd(fds[i],rd);
	}
}

//! Sets write watch on all descriptors
void Select::writeall(){
	#ifdef TRACE
	T(std::cout, "Enters Select::writeall");
	#endif
	for(int i=0;i<maxstates;i++){
		setfd(fds[i],wr);
	}
}

//! Sets exception watch on all descriptors
void Select::excepall(){
	#ifdef TRACE
	T(std::cout, "Enters Select::excepall");
	#endif
	for(int i=0;i<maxstates;i++){
		setfd(fds[i],er);
	}
}



//! Calls pselect with sigmask set to NULL
int Select::waitonselect(){
	#ifdef TRACE
	T(std::cout,  "Enters Select::waitonselect");
	#endif
	//The same as select (sigmask = NULL)
	return pselect(hfd+1,&rd,&wr,&er,NULL,NULL);
}

//! Calls pselect and waits for fds and the desired signal
int Select::waitonpselect(){
	#ifdef TRACE
	T(std::cout, "Enters Select::waitonpselect");
	#endif
	return pselect(hfd+1,&rd,&wr,&er,NULL,&emptyset);
}

void Select::clearfdread(int fd){
	#ifdef TRACE
	T(std::cout, "Enters Select::clearfread");
	#endif
	clearfd(fd,rd);
}
	
void Select::clearfdwrite(int fd){
	#ifdef TRACE
	T(std::cout, "Enters Select::clearfdwrite");
	#endif
	clearfd(fd,wr);
}

void Select::clearfdexcep(int fd){
	#ifdef TRACE
	T(std::cout,  "Enters Select::clearfdexcep");
	#endif
	clearfd(fd,er);
}

void Select::setfdread(int const &pos){
	#ifdef TRACE
	T(std::cout,  "Enters Select::setfdread");
	#endif
	#ifdef DEBUG_SEL
	D(std::cout,pos);
	D(std::cout,nfds);
	#endif
	#ifdef VALIDATION
	assert(pos<maxstates);
	#endif
	if(pos < maxstates) setfd(fds[pos],rd);
}

void Select::setfdwrite(int const &pos){
	#ifdef TRACE
	T(std::cout,  "Enters Select::clearfdwrite");
	#endif
	#ifdef DEBUG_SEL
	D(std::cout,pos);
	D(std::cout,nfds);
	#endif
	#ifdef VALIDATION
	assert(pos<maxstates);
	#endif
	if(pos < maxstates) setfd(fds[pos],rd);
}

void Select::setfdexcep(int const &pos){
	#ifdef TRACE
	T(std::cout,  "Enters Select::setfdexcep");
	#endif
	#ifdef DEBUG_SEL
	D(std::cout,pos);
	D(std::cout,nfds);
	#endif
	#ifdef VALIDATION
	assert(pos<maxstates);
	#endif
	if(pos < maxstates) setfd(fds[pos],er);
}

bool Select::isfdread(int const &pos){
	#ifdef TRACE
	T(std::cout,  "Enters Select::isfdread");
	#endif
	#ifdef DEBUG_SEL
	D(std::cout,pos);
	D(std::cout,nfds);
	#endif
	#ifdef VALIDATION
	assert(pos<maxstates);
	#endif
	bool set = false;
	if(pos < maxstates) 
		set = issetfd(fds[pos],rd);
	return set;
}

bool Select::isfdwrite(int const &pos){
	#ifdef TRACE
	T(std::cout,  "Enters Select::isfdwrite");
	#endif
	#ifdef VALIDATION
	assert(pos<maxstates);
	#endif
	#ifdef DEBUG_SEL
	D(std::cout,pos);
	D(std::cout,nfds);
	#endif
	bool set = false;
	if(pos < maxstates) 
		set = issetfd(fds[pos],wr);
	return set;
}

bool Select::isfdexcep(int const &pos){
	#ifdef TRACE
	T(std::cout,  "Enters Select::isfdexcep");
	#endif
	#ifdef DEBUG_SEL
	D(std::cout,pos);
	D(std::cout,nfds);
	#endif
	#ifdef VALIDATION
	assert(pos<maxstates);
	#endif
	bool set = false;
	if(pos < maxstates) 
		set = issetfd(fds[pos],er);
	return set;
}






