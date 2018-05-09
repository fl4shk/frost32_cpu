#include "allocation_stuff.hpp"

class DupStuff
{
	friend int* cstm_intdup(int to_dup);
	friend std::string* cstm_strdup(const std::string& to_dup);

private:			// static variables
	static std::map<int, std::unique_ptr<int>> __int_pool;
	static std::map<std::string, std::unique_ptr<std::string>>
		__str_pool;

};

std::map<int, std::unique_ptr<int>> DupStuff::__int_pool;
std::map<std::string, std::unique_ptr<std::string>> DupStuff::__str_pool;

int* cstm_intdup(int to_dup)
{
	auto& pool = DupStuff::__int_pool;

	if (pool.count(to_dup) == 0)
	{
		std::unique_ptr<int> to_insert;
		to_insert.reset(new int());
		*to_insert = to_dup;
		pool[to_dup] = std::move(to_insert);
	}

	return pool.at(to_dup).get();
}

std::string* cstm_strdup(const std::string& to_dup)
{
	auto& pool = DupStuff::__str_pool;

	if (pool.count(to_dup) == 0)
	{
		std::unique_ptr<std::string> to_insert;
		to_insert.reset(new std::string());
		*to_insert = to_dup;
		pool[to_dup] = std::move(to_insert);
	}

	return pool.at(to_dup).get();
}
