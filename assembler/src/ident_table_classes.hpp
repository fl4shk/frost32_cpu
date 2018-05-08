#ifndef ident_table_classeses_hpp
#define ident_table_classeses_hpp


#include "misc_includes.hpp"

typedef std::string* Ident;

template<typename Type>
class IdentTable
{
private:		// variables
	std::map<Ident, Type> __table;

public:		// functions
	inline IdentTable()
	{
	}

	// Type accessors
	inline Type& at(Ident some_name)
	{
		return __table[some_name];
	}

	inline const Type& at(Ident some_name) const
	{
		return __table.at(some_name);
	}

	inline bool contains(Ident some_name) const
	{
		return (__table.count(some_name) == 1);
	}

	inline void insert_or_assign(const Type& to_insert_or_assign)
	{
		at(to_insert_or_assign.name()) = to_insert_or_assign;
	}
	inline void insert_or_assign(Type&& to_insert_or_assign)
	{
		at(to_insert_or_assign.name()) = std::move(to_insert_or_assign);
	}

	gen_getter_by_con_ref(table);
};

template<typename Type>
class IdentToPointerTable
{
private:		// variables
	std::map<Ident, Type*> __table;

public:		// functions
	inline IdentToPointerTable()
	{
	}

	// Type accessors
	inline auto& at(Ident some_name)
	{
		return __table[some_name];
	}

	inline const auto& at(Ident some_name) const
	{
		return __table.at(some_name);
	}

	inline bool contains(Ident some_name) const
	{
		return (__table.count(some_name) == 1);
	}

	inline void insert_or_assign(Type* to_insert_or_assign)
	{
		at(to_insert_or_assign->name()) = to_insert_or_assign;
	}

	gen_getter_by_con_ref(table);
	gen_getter_by_ref(table);
};


#endif		// ident_table_classeses_hpp
