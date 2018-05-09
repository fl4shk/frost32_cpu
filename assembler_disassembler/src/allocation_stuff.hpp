#ifndef src__slash__allocation_stuff_hpp
#define src__slash__allocation_stuff_hpp

// src/allocation_stuff.hpp

#include "misc_includes.hpp"


#include <map>

int* cstm_intdup(int to_dup);
std::string* cstm_strdup(const std::string& to_dup);

#endif		// src__slash__allocation_stuff_hpp
